//
//  vu_ui_utils.mm
//

#include "vu_ui_utils.hpp"
#include "yas_audio.h"

using namespace yas;

ui::angle vu::ui_utils::meter_angle(float const in_value, float const reference, float const half_degrees) {
    float const db_value = audio::math::decibel_from_linear(in_value);
    float const value = audio::math::linear_from_decibel(db_value - reference);

    static float const min = audio::math::linear_from_decibel(-20.0);
    static float const max = audio::math::linear_from_decibel(3.0);
    static float const min_to_max = max - min;

    static float const max_degrees = -(half_degrees + (0.0f - min) / min_to_max * -half_degrees * 2.0f);

    float const degrees = half_degrees + (value - min) / min_to_max * -half_degrees * 2.0f;

    return {.degrees = std::max(degrees, max_degrees)};
}

float vu::ui_utils::gridline_y(ui::angle const angle, ui::angle const half_angle, float const y, float const rate) {
    float const side_y = std::cos(half_angle.radians()) * y;
    float const top_y = std::cos(angle.radians()) * y;
    return y - (top_y - side_y) * rate;
}
