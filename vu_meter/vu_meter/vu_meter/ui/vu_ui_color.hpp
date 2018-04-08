//
//  vu_ui_color.hpp
//

#pragma once

#import <Metal/Metal.h>
#include "yas_ui.h"

namespace yas::vu {
MTLClearColor const &base_color();
    
ui::color const &indicator_base_color();
ui::color const &indicator_needle_color();
ui::color const &indicator_gridline_color();
ui::color const &indicator_number_color();
    
    ui::color const &reference_button_color();
}
