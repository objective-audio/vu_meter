//
//  vu_main.hpp
//

#pragma once

#include "yas_audio.h"
#include "vu_data.hpp"
#include "vu_ui_main.hpp"
#include <atomic>
#include <array>

namespace yas::vu {
class main {
    audio::engine::manager manager;
    audio::engine::au_input au_input;
    audio::engine::tap input_tap = {{.is_input = true}};

   public:
    std::array<std::atomic<float>, 2> values{0.0f, 0.0f};

    vu::data data;

    void setup();
};
}
