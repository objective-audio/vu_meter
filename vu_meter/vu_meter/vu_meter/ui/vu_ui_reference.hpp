//
//  vu_ui_reference.hpp
//

#pragma once

#include "vu_data.hpp"
#include "vu_types.h"
#include "yas_ui.h"

namespace yas::vu {
class main;

struct ui_reference {
    ui::node node;
    ui::button minus_button{nullptr};
    ui::button plus_button{nullptr};
    ui::font_atlas font_atlas{nullptr};
    ui::strings text{nullptr};
    ui::layout_guide_rect layout_guide_rect;

    void setup(main_ptr_t &main, ui::texture &texture);

   private:
    base _data_flow = nullptr;
    base _minus_flow = nullptr;
    base _plus_flow = nullptr;
    ui::layout_guide_point _minus_layout_guide_point;
    ui::layout_guide_point _plus_layout_guide_point;
    ui::layout_guide_point _text_layout_guide_point;
    ui::layout_guide_point _center_guide_point;
    std::vector<flow::observer> _flows;

    void _setup_minus_button(ui::texture &);
    void _setup_plus_button(ui::texture &);
    void _setup_text(ui::texture &);
    void _setup_data_flows(main_ptr_t &);
    void _setup_layout_flows();

    void _update_text(int32_t const);
};
}  // namespace yas::vu
