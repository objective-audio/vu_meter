//
//  vu_main.hpp
//

#pragma once

#include <audio/yas_audio_umbrella.h>
#include <chaining/yas_chaining_umbrella.h>
#include <mutex>
#include "vu_data.hpp"
#include "vu_types.h"
#include "vu_ui_main.hpp"

namespace yas::vu {
struct main {
    vu::data_ptr data = vu::data::make_shared();
    chaining::value::holder_ptr<uint32_t> indicator_count = chaining::value::holder<uint32_t>::make_shared(uint32_t(0));

    void setup();

    void set_values(std::vector<float> &&);
    std::vector<float> values();

    static main_ptr_t make_shared();

   private:
    audio::engine::manager_ptr manager = audio::engine::manager::make_shared();
    audio::engine::tap_ptr input_tap = audio::engine::tap::make_shared({.is_input = true});

    std::vector<float> _values;
    std::mutex _values_mutex;

    uint32_t _input_channel_count();
    double _sample_rate();
    void _update_indicator_count();
    void _update_timeline();

    chaining::observer_pool _observers;

    uint32_t _last_ch_count = 0;
    double _last_sample_rate = 0.0;

    main();
};
}  // namespace yas::vu
