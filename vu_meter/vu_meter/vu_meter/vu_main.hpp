//
//  vu_main.hpp
//

#pragma once

#include "yas_audio.h"

namespace yas::vu {
class main {
    audio::engine::manager manager = nullptr;

   public:
    void setup();
};
}
