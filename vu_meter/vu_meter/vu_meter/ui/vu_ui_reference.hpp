//
//  vu_ui_reference.hpp
//

#pragma once

#include "vu_data.hpp"
#include "vu_types.h"
#include "yas_ui.h"

namespace yas::vu {
class main;

struct ui_stepper {
    ui::node node;
    ui::button minus_button{nullptr};
    ui::button plus_button{nullptr};
    ui::font_atlas font_atlas{nullptr};
    ui::strings text{nullptr};
    ui::layout_guide_rect layout_guide_rect;

    void setup(ui::texture &texture);

    auto begin_minus_flow();
    auto begin_plus_flow();
    flow::receiver<std::string> &text_receiver();

   private:
    ui::layout_guide_point _minus_layout_guide_point;
    ui::layout_guide_point _plus_layout_guide_point;
    ui::layout_guide_point _text_layout_guide_point;
    ui::layout_guide_point _center_guide_point;
    std::vector<flow::observer> _flows;

    void _setup_minus_button(ui::texture &);
    void _setup_plus_button(ui::texture &);
    void _setup_text(ui::texture &);
    void _setup_flows();

    void _update_text(int32_t const);
};

struct ui_reference {
    void setup(main_ptr_t &main, ui::texture &texture);

    ui::node &node();
    ui::layout_guide_rect &layout_guide_rect();

   private:
    ui_stepper _stepper;
    std::vector<flow::observer> _flows;

    void _setup_flows(main_ptr_t &);
};
}  // namespace yas::vu
