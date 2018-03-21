//
//  vu_main.mm
//

#include "vu_main.hpp"
#include "vu_send_module.hpp"
#include <limits>
#include <iostream>

using namespace yas;

void vu::main::setup() {
    NSError *error = nil;

    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error]) {
        NSLog(@"error : %@", error);
        return;
    }

    double const sample_rate = this->au_input.au_io().device_sample_rate();
    audio::format format{{.sample_rate = sample_rate, .channel_count = 2}};
    this->manager.connect(this->au_input.au_io().au().node(), this->input_tap.node(), format);

    struct context_t {
        audio::pcm_buffer &buffer = null_buffer();

        void reset_buffer() {
            this->buffer = this->null_buffer();
        }

        static audio::pcm_buffer &null_buffer() {
            static audio::pcm_buffer _null_buffer{nullptr};
            return _null_buffer;
        }
    };

    auto context = std::make_shared<context_t>();

    proc::timeline timeline{};

    if (auto track = timeline.add_track(0)) {
        auto send_module = vu::send::make_signal_module([context](
            proc::time::range const &time_range, proc::connector_index_t const &co_idx, float *const signal_ptr) {
            auto &buffer = context->buffer;
            if (!buffer) {
                return;
            }

            auto const &format = buffer.format();
            bool const is_interleaved = format.is_interleaved();
            auto const ch_count = format.channel_count();

            if (!is_interleaved && co_idx < ch_count) {
                float *in_ptr = buffer.data_ptr_at_channel<float>(co_idx);
                memcpy(signal_ptr, in_ptr, time_range.length * sizeof(float));
            }
        });

        send_module.connect_output(proc::to_connector_index(vu::send::output::left), 0);
        send_module.connect_output(proc::to_connector_index(vu::send::output::right), 1);

        proc::time::range time_range{0, std::numeric_limits<proc::frame_index_t>::max()};
        track.insert_module(time_range, std::move(send_module));
    }

    this->input_tap.set_render_handler([context, timeline](audio::engine::node::render_args args) mutable {
        proc::length_t const length = args.buffer.frame_length();
        context->buffer = args.buffer;

        proc::time::range const time_range{args.when.sample_time(), length};
        proc::sync_source const sync_source{static_cast<proc::sample_rate_t>(args.when.sample_rate()), length};
        proc::stream stream{sync_source};

        timeline.process(time_range, stream);

        for (auto const ch : {0, 1}) {
            if (stream.has_channel(ch)) {
                auto const &channel = stream.channel(ch);
                auto events = channel.filtered_events<float, proc::signal_event>();
                for (auto const &event_pair : events) {
                    auto const &time_range = event_pair.first;
                    auto const &event = event_pair.second;
                    std::cout << "ch:" << ch << "time_range:" << to_string(time_range)
                              << " event.first:" << event.vector<float>().at(0) << std::endl;
                }
            }
        }
#warning todo process後にdb値を残す

        context->reset_buffer();
    });

    if (auto result = this->manager.start_render(); !result) {
        std::cout << "error : " << result.error() << std::endl;
    }
}
