//
//  vu_ui_reference.hpp
//

#pragma once

#include "yas_ui.h"

namespace yas::vu {
struct ui_reference {
    ui::node node;
    ui::button minus_button{ui::region::zero_centered(ui::size{60.0f, 60.0f})};
    ui::button plus_button{ui::region::zero_centered(ui::size{60.0f, 60.0f})};
    ui::font_atlas font_atlas{nullptr};
    ui::strings text{nullptr};

    void setup(ui::texture &texture);
};
}
