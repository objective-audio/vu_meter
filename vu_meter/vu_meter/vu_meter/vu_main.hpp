//
//  vu_main.hpp
//

#pragma once

#include "yas_audio.h"
#include <atomic>
#include <array>

namespace yas::vu {
class main {
    audio::engine::manager manager;
    audio::engine::au_input au_input;
    audio::engine::tap input_tap = {{.is_input = true}};

    std::array<std::atomic<float>, 2> db_values{0.0f, 0.0f};

   public:
    void setup();
};
}
