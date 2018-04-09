//
//  vu_ui_utils.hpp
//

#pragma once

#include "yas_ui.h"

namespace yas::vu::ui_utils {
ui::angle meter_angle(float const in_value, float const reference, float const half_degrees);
float gridline_y(ui::angle const angle, ui::angle const half_angle, float const y, float const rate);
}
