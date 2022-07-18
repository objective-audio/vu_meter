//
//  vu_main.hpp
//

#pragma once

#include <audio/yas_audio_umbrella.h>
#include <observing/yas_observing_umbrella.h>

#include "vu_audio_types.h"

namespace yas::vu {
class settings;
class indicator;
class indicator_values;

struct main {
    [[nodiscard]] static std::shared_ptr<main> make_shared(indicator_values *);

    void setup();

   private:
    std::shared_ptr<settings> const _settings;
    indicator_values *const _indicator_values;

    std::optional<audio::ios_device_ptr> _device = std::nullopt;
    audio::graph_ptr const _graph = audio::graph::make_shared();
    audio::graph_input_tap_ptr const _input_tap = audio::graph_input_tap::make_shared();

    audio_format _format() const;
    uint32_t _input_channel_count() const;
    double _sample_rate() const;
    void _update_indicators();
    void _update_timeline();

    observing::canceller_pool _pool;

    audio_format _last_format;

    main(indicator_values *);
};
}  // namespace yas::vu
