//
//  vu_ui_utils.hpp
//

#pragma once

#include "yas_ui.h"

namespace yas::vu::ui_utils {
ui::angle meter_angle(float const in_value, float const reference);
float gridline_y(float const angle, float const top, float const side);
}
