//
//  vu_ui_reference.hpp
//

#pragma once

#include "yas_ui.h"
#include "vu_types.h"
#include "vu_data.hpp"

namespace yas::vu {
class main;

struct ui_reference {
    ui::node node;
    ui::button minus_button{ui::region::zero_centered(ui::size{60.0f, 60.0f})};
    ui::button plus_button{ui::region::zero_centered(ui::size{60.0f, 60.0f})};
    ui::font_atlas font_atlas{nullptr};
    ui::strings text{nullptr};
    ui::layout_guide_point layout_guide_point;

    void setup(main_ptr_t &main, ui::texture &texture);

   private:
    std::vector<ui::button::observer_t> _button_observers;
    vu::data::observer_t _data_observer = nullptr;

    void _update_ui(int32_t const);
};
}
