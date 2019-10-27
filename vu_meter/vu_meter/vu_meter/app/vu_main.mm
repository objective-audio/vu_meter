//
//  vu_main.mm
//

#include "vu_main.hpp"
#include <audio/yas_audio_umbrella.h>
#include <cpp_utils/yas_fast_each.h>
#include <iostream>
#include <limits>
#include "vu_send_module.hpp"
#include "vu_sum_module.hpp"

#import <AVFoundation/AVFoundation.h>

using namespace yas;

void vu::main::setup() {
    NSError *error = nil;

    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error]) {
        NSLog(@"error : %@", error);
        return;
    }

    if (![[AVAudioSession sharedInstance] setActive:YES error:&error]) {
        NSLog(@"%@", error);
        return;
    }

    this->manager->add_io();

    this->_update_timeline();
    this->_update_indicator_count();

    this->_observers += this->manager->chain(audio::engine::manager::method::configuration_change)
                            .perform([this](auto const &) {
                                this->_update_timeline();
                                this->_update_indicator_count();
                            })
                            .end();
}

uint32_t vu::main::_input_channel_count() {
    if (auto const &device = this->manager->io().value()->device()) {
        return device.value()->input_channel_count();
    }
    return 0;
}

double vu::main::_sample_rate() {
    if (auto const &device = this->manager->io().value()->device()) {
        if (auto const &format = device.value()->input_format()) {
            return format.value().sample_rate();
        }
    }
    return 0;
}

void vu::main::_update_indicator_count() {
    this->indicator_count->set_value(this->_input_channel_count());
}

void vu::main::_update_timeline() {
    uint32_t const ch_count = this->_input_channel_count();
    double const sample_rate = this->_sample_rate();

    if (this->_last_ch_count == ch_count && this->_last_sample_rate == sample_rate) {
        return;
    }

    this->manager->stop();
    this->manager->disconnect_input(this->input_tap->node());

    this->_last_ch_count = ch_count;
    this->_last_sample_rate = sample_rate;

    if (ch_count == 0) {
        return;
    }

    audio::format format{{.sample_rate = sample_rate, .channel_count = ch_count}};
    this->manager->connect(this->manager->io().value()->node(), this->input_tap->node(), format);

    struct context_t {
        audio::pcm_buffer *buffer = nullptr;

        void reset_buffer() {
            this->buffer = nullptr;
        }
    };

    auto context = std::make_shared<context_t>();

    proc::timeline_ptr timeline = proc::timeline::make_shared();
    proc::track_index_t trk_idx = 0;
    proc::time::range time_range{0, std::numeric_limits<proc::frame_index_t>::max()};
    proc::channel_index_t const pow_ch = ch_count;

    /// インプットを受け付けるトラック
    if (auto each = make_fast_each(ch_count); true) {
        while (yas_each_next(each)) {
            std::size_t const &ch = yas_each_index(each);

            if (auto track = proc::track::make_shared()) {
                auto module = vu::send::make_signal_module([context, ch](proc::time::range const &time_range,
                                                                         proc::connector_index_t const &,
                                                                         float *const signal_ptr) {
                    auto const &buffer = context->buffer;
                    if (!buffer) {
                        return;
                    }

                    uint32_t const length = std::min(buffer->frame_length(), static_cast<uint32_t>(time_range.length));
                    buffer->copy_to(signal_ptr, 1, 0, static_cast<uint32_t>(ch), 0, length);
                });

                module->connect_output(proc::to_connector_index(vu::send::output::value), ch);

                track->push_back_module(module, time_range);

                timeline->insert_track(trk_idx++, track);
            }
        }
    }

    // 累乗するための固定値
    if (auto track = proc::track::make_shared()) {
        auto module = proc::make_signal_module(float(2.0f));
        module->connect_output(proc::to_connector_index(proc::constant::output::value), pow_ch);

        track->push_back_module(module, time_range);

        timeline->insert_track(trk_idx++, track);
    }

    // 累乗する
    if (auto each = make_fast_each(ch_count); true) {
        while (yas_each_next(each)) {
            std::size_t const &ch = yas_each_index(each);

            if (auto track = proc::track::make_shared()) {
                auto module = proc::make_signal_module<float>(proc::math2::kind::pow);
                module->connect_input(proc::to_connector_index(proc::math2::input::left), ch);
                module->connect_input(proc::to_connector_index(proc::math2::input::right), pow_ch);
                module->connect_output(proc::to_connector_index(proc::math2::output::result), ch);

                track->push_back_module(module, time_range);

                timeline->insert_track(trk_idx++, track);
            }
        }
    }

    // sumする
    if (auto each = make_fast_each(ch_count); true) {
        while (yas_each_next(each)) {
            std::size_t const &ch = yas_each_index(each);

            if (auto track = proc::track::make_shared()) {
                auto module = vu::sum::make_signal_module(300.0 / 1000.0);  // 300ms
                module->connect_input(proc::to_connector_index(vu::sum::input::value), ch);
                module->connect_output(proc::to_connector_index(vu::sum::output::value), ch);

                track->push_back_module(module, time_range);

                timeline->insert_track(trk_idx++, track);
            }
        }
    }

    // 平方根を取る
    if (auto each = make_fast_each(ch_count); true) {
        while (yas_each_next(each)) {
            std::size_t const &ch = yas_each_index(each);

            if (auto track = proc::track::make_shared()) {
                auto module = proc::make_signal_module<float>(proc::math1::kind::sqrt);
                module->connect_input(proc::to_connector_index(proc::math1::input::parameter), ch);
                module->connect_output(proc::to_connector_index(proc::math1::output::result), ch);

                track->push_back_module(module, time_range);

                timeline->insert_track(trk_idx++, track);
            }
        }
    }

    // デバイスのインプットからタイムラインにデータを渡す
    this->input_tap->set_render_handler([context, timeline, ch_count, this,
                                         values = std::vector<float>()](audio::engine::node::render_args args) mutable {
        proc::length_t const length = args.buffer.frame_length();
        context->buffer = &args.buffer;

        proc::time::range const time_range{args.when.sample_time(), length};
        proc::sync_source const sync_source{static_cast<proc::sample_rate_t>(args.when.sample_rate()), length};
        proc::stream stream{sync_source};

        timeline->process(time_range, stream);

        values.clear();

        if (auto each = make_fast_each(ch_count); true) {
            while (yas_each_next(each)) {
                std::size_t const &ch = yas_each_index(each);

                if (stream.has_channel(ch)) {
                    auto const &channel = stream.channel(ch);
                    auto events = channel.filtered_events<float, proc::signal_event>();
                    for (auto const &event_pair : events) {
                        auto const &event = event_pair.second;

                        values.push_back(event->vector<float>().at(ch));
                    }
                }
            }
        }

        this->set_values(std::move(values));

        context->reset_buffer();
    });

    if (auto result = this->manager->start_render(); !result) {
        std::cout << "error : " << result.error() << std::endl;
    }
}

void vu::main::set_values(std::vector<float> &&values) {
    std::lock_guard<std::mutex> lock(_values_mutex);
    this->_values = std::move(values);
}

std::vector<float> vu::main::values() {
    std::vector<float> values;
    if (std::lock_guard<std::mutex> lock(_values_mutex); true) {
        values = this->_values;
    }
    return values;
}

vu::main_ptr_t vu::main::make_shared() {
    auto shared = std::shared_ptr<main>(new main{});
    shared->setup();
    return shared;
}
