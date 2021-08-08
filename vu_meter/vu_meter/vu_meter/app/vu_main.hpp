//
//  vu_main.hpp
//

#pragma once

#include <audio/yas_audio_umbrella.h>
#include <observing/yas_observing_umbrella.h>

namespace yas::vu {
class settings;
class indicator;

struct main {
    std::vector<std::shared_ptr<indicator>> const &indicators() const;
    observing::syncable observe_indicators(std::function<void(std::vector<std::shared_ptr<indicator>> const &)> &&);

    static std::shared_ptr<main> make_shared();

   private:
    std::shared_ptr<settings> const _settings;

    observing::value::holder_ptr<std::vector<std::shared_ptr<indicator>>> const _indicators;

    std::optional<audio::ios_device_ptr> _device = std::nullopt;
    audio::graph_ptr const _graph = audio::graph::make_shared();
    audio::graph_input_tap_ptr const _input_tap = audio::graph_input_tap::make_shared();

    uint32_t _input_channel_count();
    double _sample_rate();
    void _update_indicators();
    void _update_timeline();

    observing::canceller_pool _pool;

    std::size_t _last_ch_count = 0;
    double _last_sample_rate = 0.0;

    main();
};
}  // namespace yas::vu
