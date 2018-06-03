//
//  vu_ui_stepper.hpp
//

#pragma once

#include "vu_types.h"
#include "yas_ui.h"

namespace yas::vu {
struct ui_stepper_resource : base {
    class impl;

    ui_stepper_resource(ui::texture &texture);
    ui_stepper_resource(std::nullptr_t);

    std::vector<ui::texture_element> const &minus_elements();
    std::vector<ui::texture_element> const &plus_elements();
};

struct ui_stepper {
    using button_flow_t =
        flow::node<ui::button::context, ui::button::subject_t::flow_context_t, ui::button::subject_t::flow_context_t>;

    ui::node node;
    ui::layout_guide_rect layout_guide_rect;

    void setup(ui::texture &texture);

    button_flow_t begin_minus_flow();
    button_flow_t begin_plus_flow();
    flow::receiver<std::string> &text_receiver();
    flow::receiver<bool> &minus_enabled_receiver();
    flow::receiver<bool> &plus_enabled_receiver();

   private:
    ui::button _minus_button{nullptr};
    ui::button _plus_button{nullptr};
    ui::font_atlas _font_atlas{nullptr};
    ui::strings _text{nullptr};

    ui::layout_guide_point _minus_layout_guide_point;
    ui::layout_guide_point _plus_layout_guide_point;
    ui::layout_guide_point _text_layout_guide_point;
    ui::layout_guide_point _center_guide_point;
    flow::sender<bool> _minus_enabled_setter;
    flow::sender<bool> _plus_enabled_setter;
    std::vector<flow::observer> _flows;

    void _setup_minus_button(ui::texture &);
    void _setup_plus_button(ui::texture &);
    void _setup_text(ui::texture &);
    void _setup_flows();

    void _update_text(int32_t const);
};
}  // namespace yas::vu
