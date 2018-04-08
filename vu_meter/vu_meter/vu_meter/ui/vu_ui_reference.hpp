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
    ui::layout_guide_rect layout_guide_rect;

    void setup(main_ptr_t &main, ui::texture &texture);

   private:
    std::vector<ui::button::observer_t> _button_observers;
    vu::data::observer_t _data_observer = nullptr;
    ui::layout_guide_point _minus_layout_guide_point;
    ui::layout_guide_point _plus_layout_guide_point;
    ui::layout_guide_point _text_layout_guide_point;
    std::vector<ui::layout> _layouts;

    void _setup_minus_button(weak_main_ptr_t &weak_main, ui::texture &texture);
    void _setup_plus_button(weak_main_ptr_t &weak_main, ui::texture &texture);
    void _setup_text(main_ptr_t &main, ui::texture &texture);
    void _setup_layout();
    
    void _update_ui(int32_t const);
};
}
