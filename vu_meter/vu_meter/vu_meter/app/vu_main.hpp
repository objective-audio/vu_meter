//
//  vu_main.hpp
//

#pragma once

#include <array>
#include <atomic>
#include "vu_data.hpp"
#include "vu_types.h"
#include "vu_ui_main.hpp"
#include "yas_audio.h"

namespace yas::vu {
class main {
    audio::engine::manager manager;
    audio::engine::au_input au_input;
    audio::engine::tap input_tap = {{.is_input = true}};

   public:
    std::array<std::atomic<float>, vu::indicator_count_max> values{0.0f, 0.0f, 0.0f, 0.0f};

    vu::data data;

    void setup();
};
}  // namespace yas::vu
