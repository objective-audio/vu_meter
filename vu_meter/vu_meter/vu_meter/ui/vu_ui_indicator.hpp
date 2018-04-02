//
//  vu_indicator.hpp
//

#pragma once

#include "yas_ui.h"

namespace yas::vu {
struct ui_indicator {
    ui::node node;
    ui::rect_plane needle = ui::make_rect_plane(1);
    std::vector<ui::rect_plane> gridlines;
    std::vector<ui::strings> numbers;

    void setup(ui::texture &texture);
    
    void set_value(float const);
};
}
