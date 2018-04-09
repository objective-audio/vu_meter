//
//  vu_ui_utils.mm
//

#include "vu_ui_utils.hpp"
#include "yas_audio.h"

using namespace yas;

namespace yas::vu {
static float constexpr half_degrees = 50.0f;
}

ui::angle vu::ui_utils::meter_angle(float const in_value, float const reference) {
    float const db_value = audio::math::decibel_from_linear(in_value);
    float const value = audio::math::linear_from_decibel(db_value - reference);

    static float const min = audio::math::linear_from_decibel(-20.0);
    static float const max = audio::math::linear_from_decibel(3.0);
    static float const min_to_max = max - min;

    static float const max_degrees = -(vu::half_degrees + (0.0f - min) / min_to_max * -vu::half_degrees * 2.0f);

    float const degrees = vu::half_degrees + (value - min) / min_to_max * -vu::half_degrees * 2.0f;

    return {.degrees = std::max(degrees, max_degrees)};
}

float vu::ui_utils::gridline_y(float const angle, float const top, float const side) {
    float const rate = std::abs(angle) / vu::half_degrees;
    float const dif = side - top;
    return top + dif * rate;
}
