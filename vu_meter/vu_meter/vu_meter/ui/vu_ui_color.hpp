//
//  vu_ui_color.hpp
//

#pragma once

#import <Metal/Metal.h>
#include <ui/yas_ui_umbrella.h>

namespace yas::vu {
MTLClearColor const &base_color();

ui::color const &indicator_base_color();
ui::color const &indicator_needle_color();
ui::color const &indicator_gridline_color();
ui::color const &indicator_number_color();
ui::color const &indicator_ch_color();
ui::color const &indicator_over_gridline_color();
ui::color const &indicator_over_number_color();

ui::color const &setting_button_base_color(bool const is_tracking);
ui::color const &setting_text_color();
}  // namespace yas::vu
