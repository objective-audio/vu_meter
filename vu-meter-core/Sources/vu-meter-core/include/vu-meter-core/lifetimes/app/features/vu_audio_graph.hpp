//
//  vu_audio_graph.hpp
//

#pragma once

#include <observing/umbrella.hpp>
#include <vu-meter-core/lifetimes/app/value_types/vu_audio_format.hpp>

namespace yas::audio {
class graph;
class graph_input_tap;
}  // namespace yas::audio

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

    std::shared_ptr<audio::graph> const _graph;
    std::shared_ptr<audio::graph_input_tap> const _input_tap;

    void _update(audio_format const &);

    observing::canceller_pool _pool;
};
}  // namespace yas::vu
