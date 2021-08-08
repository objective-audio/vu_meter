//
//  vu_main.hpp
//

#pragma once

#include <audio/yas_audio_umbrella.h>
#include <observing/yas_observing_umbrella.h>

#include <mutex>

#include "vu_settings.hpp"
#include "vu_ui_main.hpp"

namespace yas::vu {
struct main {
    std::shared_ptr<settings> const settings = vu::settings::make_shared();

    void set_indicator_count(uint32_t const);
    uint32_t indicator_count() const;
    observing::syncable observe_indicator_count(std::function<void(uint32_t const &)> &&);

    void set_values(std::vector<float> &&);
    std::vector<float> values();

    static std::shared_ptr<main> make_shared();

   private:
    observing::value::holder_ptr<uint32_t> const _indicator_count =
        observing::value::holder<uint32_t>::make_shared(uint32_t(0));

    std::optional<audio::ios_device_ptr> _device = std::nullopt;
    audio::graph_ptr const _graph = audio::graph::make_shared();
    audio::graph_input_tap_ptr const _input_tap = audio::graph_input_tap::make_shared();

    std::vector<float> _values;
    std::mutex _values_mutex;

    uint32_t _input_channel_count();
    double _sample_rate();
    void _update_indicator_count();
    void _update_timeline();

    observing::canceller_pool _pool;

    uint32_t _last_ch_count = 0;
    double _last_sample_rate = 0.0;

    main();
};
}  // namespace yas::vu
