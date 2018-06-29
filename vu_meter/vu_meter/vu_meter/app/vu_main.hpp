//
//  vu_main.hpp
//

#pragma once

#include <mutex>
#include "vu_data.hpp"
#include "vu_types.h"
#include "vu_ui_main.hpp"
#include "yas_audio.h"
#include "yas_flow.h"

namespace yas::vu {
struct main {
    vu::data data;
    flow::property<uint32_t> indicator_count{uint32_t(0)};

    void setup();

    void set_values(std::vector<float> &&);
    std::vector<float> values();

   private:
    audio::engine::manager manager;
    audio::engine::au_input au_input;
    audio::engine::tap input_tap = {{.is_input = true}};

    std::vector<float> _values;
    std::mutex _values_mutex;

    void _update_indicator_count();
    void _update_timeline();

    flow::observer _manager_flow = nullptr;

    uint32_t _last_ch_count = 0;
    double _last_sample_rate = 0.0;
};
}  // namespace yas::vu
