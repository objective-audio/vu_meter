//
//  vu_ui_utils.mm
//

#include "vu_ui_utils.hpp"
#include "yas_audio.h"

using namespace yas;

ui::angle vu::ui_utils::meter_angle(float const in_value, float const reference) {
    float const db_value = audio::math::decibel_from_linear(in_value);
    float const value = audio::math::linear_from_decibel(db_value - reference);

    float const min = audio::math::linear_from_decibel(-20.0);
    float const max = audio::math::linear_from_decibel(3.0);
    float const min_to_max = max - min;

    return {.degrees = 45.0f + (value - min) / min_to_max * -90.0f};
}
