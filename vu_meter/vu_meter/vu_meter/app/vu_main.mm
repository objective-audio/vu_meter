//
//  vu_main.mm
//

#include "vu_main.hpp"
#import <AVFoundation/AVFoundation.h>
#include <audio/yas_audio_umbrella.h>
#include <cpp_utils/yas_fast_each.h>
#include <iostream>
#include <limits>
#include "vu_indicator.hpp"
#include "vu_send_module.hpp"
#include "vu_settings.hpp"
#include "vu_sum_module.hpp"

using namespace yas;
using namespace yas::vu;

main::main()
    : _settings(vu::settings::make_shared()),
      _indicators(observing::value::holder<std::vector<std::shared_ptr<indicator>>>::make_shared({})) {
    yas_audio_set_log_enabled(true);

    auto const &session = audio::ios_session::shared();

    session->set_category(audio::ios_session::category::record);
    auto const result = session->activate();
    if (!result) {
        std::cout << "session activate result : " << result.error() << std::endl;
        return;
    }

    this->_device = audio::ios_device::make_shared(session);

    this->_graph->add_io(this->_device);

    this->_update_indicators();

    this->_device.value()
        ->observe_io_device([this](auto const &) { this->_update_indicators(); })
        .end()
        ->add_to(this->_pool);
}

std::vector<std::shared_ptr<indicator>> const &main::indicators() const {
    return this->_indicators->value();
}

observing::syncable main::observe_indicators(
    std::function<void(std::vector<std::shared_ptr<indicator>> const &)> &&handler) {
    return this->_indicators->observe(std::move(handler));
}

uint32_t main::_input_channel_count() {
    if (auto const &device = this->_device) {
        return device.value()->input_channel_count();
    }
    return 0;
}

double main::_sample_rate() {
    if (auto const &device = this->_device) {
        if (auto const &format = device.value()->input_format()) {
            return format.value().sample_rate();
        }
    }
    return 0;
}

void main::_update_indicators() {
    auto const ch_count = this->_input_channel_count();
    auto const prev_count = this->_indicators->value().size();

    if (ch_count < prev_count) {
        auto indicators = this->_indicators->value();
        indicators.resize(ch_count);
        this->_indicators->set_value(std::move(indicators));
    } else if (ch_count > prev_count) {
        auto const diff_count = ch_count - prev_count;
        auto indicators = this->_indicators->value();
        auto each = make_fast_each(diff_count);
        while (yas_each_next(each)) {
            indicators.emplace_back(indicator::make_shared(this->_settings));
        }
        this->_indicators->set_value(std::move(indicators));
    }

    this->_update_timeline();
}

void main::_update_timeline() {
    auto const ch_count = this->_indicators->value().size();
    double const sample_rate = this->_sample_rate();

    if (this->_last_ch_count == ch_count && this->_last_sample_rate == sample_rate) {
        return;
    }

    this->_graph->stop();
    this->_graph->disconnect_input(this->_input_tap->node);

    this->_last_ch_count = ch_count;
    this->_last_sample_rate = sample_rate;

    if (ch_count == 0) {
        return;
    }

    audio::format const format{{.sample_rate = sample_rate, .channel_count = static_cast<uint32_t>(ch_count)}};
    this->_graph->connect(this->_graph->io().value()->input_node, this->_input_tap->node, format);

    struct context_t {
        audio::pcm_buffer const *buffer = nullptr;

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
                auto module = send::make_signal_module([context, ch](proc::time::range const &time_range,
                                                                     proc::connector_index_t const &,
                                                                     float *const signal_ptr) {
                    audio::pcm_buffer const *const buffer = context->buffer;
                    if (!buffer) {
                        return;
                    }

                    uint32_t const length = std::min(buffer->frame_length(), static_cast<uint32_t>(time_range.length));
                    buffer->copy_to(signal_ptr, 1, 0, static_cast<uint32_t>(ch), 0, length);
                });

                module->connect_output(proc::to_connector_index(send::output::value), ch);

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
                auto module = sum::make_signal_module(300.0 / 1000.0);  // 300ms
                module->connect_input(proc::to_connector_index(sum::input::value), ch);
                module->connect_output(proc::to_connector_index(sum::output::value), ch);

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
    this->_input_tap->set_render_handler([context, timeline, indicators = this->_indicators->value()](
                                             audio::node_input_render_args const &args) mutable {
        proc::length_t const length = args.buffer->frame_length();
        context->buffer = args.buffer;

        proc::time::range const time_range{args.time.sample_time(), length};
        proc::sync_source const sync_source{static_cast<proc::sample_rate_t>(args.time.sample_rate()), length};
        proc::stream stream{sync_source};

        timeline->process(time_range, stream);

        if (auto each = make_fast_each(indicators.size()); true) {
            while (yas_each_next(each)) {
                std::size_t const &ch = yas_each_index(each);

                float value = 0.0f;

                if (stream.has_channel(ch)) {
                    auto const &channel = stream.channel(ch);
                    auto events = channel.filtered_events<float, proc::signal_event>();
                    for (auto const &event_pair : events) {
                        auto const &event = event_pair.second;
                        auto const &vector = event->vector<float>();
                        if (!vector.empty()) {
                            value = vector.at(0);
                        }
                    }
                }

                indicators.at(ch)->set_raw_value(value);
            }
        }

        context->reset_buffer();
    });

    if (auto result = this->_graph->start_render(); !result) {
        std::cout << "error : " << result.error() << std::endl;
    }
}

std::shared_ptr<main> main::make_shared() {
    return std::shared_ptr<main>(new main{});
}
