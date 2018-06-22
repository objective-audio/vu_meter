//
//  vu_main.hpp
//

#pragma once

#include <array>
#include <mutex>
#include "vu_data.hpp"
#include "vu_types.h"
#include "vu_ui_main.hpp"
#include "yas_audio.h"

namespace yas::vu {
struct main {
    vu::data data;

    void setup();

    void set_values(std::vector<float> &&);
    std::vector<float> values();

   private:
    audio::engine::manager manager;
    audio::engine::au_input au_input;
    audio::engine::tap input_tap = {{.is_input = true}};

    std::vector<float> _values;
    std::mutex _values_mutex;
};
}  // namespace yas::vu
