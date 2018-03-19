//
//  vu_main.hpp
//

#pragma once

#include "yas_audio.h"

namespace yas::vu {
class main {
    audio::engine::manager manager;
    audio::engine::au_input au_input;
    audio::engine::tap input_tap = {{.is_input = true}};

   public:
    void setup();
};
}
