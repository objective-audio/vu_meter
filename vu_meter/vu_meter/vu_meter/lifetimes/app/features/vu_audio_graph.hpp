//
//  vu_audio_graph.hpp
//

#pragma once

#include <audio/yas_audio_umbrella.h>
#include <observing/yas_observing_umbrella.h>

#include "vu_audio_format.hpp"

namespace yas::vu {
class settings;
class indicator;
class indicator_values;
class audio_device;

struct audio_graph {
    [[nodiscard]] static std::shared_ptr<audio_graph> make_shared(indicator_values *, audio_device *);
    audio_graph(indicator_values *, audio_device *);

    void setup();

   private:
    indicator_values *const _indicator_values;
    audio_device *const _audio_device;

    audio::graph_ptr const _graph = audio::graph::make_shared();
    audio::graph_input_tap_ptr const _input_tap = audio::graph_input_tap::make_shared();

    void _update(audio_format const &);

    observing::canceller_pool _pool;
};
}  // namespace yas::vu
