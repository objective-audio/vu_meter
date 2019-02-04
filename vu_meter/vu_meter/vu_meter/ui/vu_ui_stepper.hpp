//
//  vu_ui_stepper.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>
#include "vu_types.h"

namespace yas::vu {
struct ui_stepper_resource : base {
    class impl;

    ui_stepper_resource(ui::texture &texture);
    ui_stepper_resource(std::nullptr_t);

    ui::texture &texture();
    std::vector<ui::texture_element> &minus_elements();
    std::vector<ui::texture_element> &plus_elements();
    ui::font_atlas const &font_atlas();
};

struct ui_stepper {
    using button_flow_t =
        chaining::chain<ui::button::context, ui::button::chain_pair_t, ui::button::chain_pair_t, false>;

    ui::node node;
    ui::layout_guide_rect layout_guide_rect;

    void setup(ui_stepper_resource &);

    button_flow_t begin_minus_flow();
    button_flow_t begin_plus_flow();
    chaining::receiver<std::string> &text_receiver();
    chaining::receiver<bool> &minus_enabled_receiver();
    chaining::receiver<bool> &plus_enabled_receiver();

   private:
    ui::button _minus_button{nullptr};
    ui::button _plus_button{nullptr};
    ui::font_atlas _font_atlas{nullptr};
    ui::strings _text{nullptr};

    ui::layout_guide_point _minus_layout_guide_point;
    ui::layout_guide_point _plus_layout_guide_point;
    ui::layout_guide_point _text_layout_guide_point;
    ui::layout_guide_point _center_guide_point;
    chaining::notifier<bool> _minus_enabled_setter;
    chaining::notifier<bool> _plus_enabled_setter;
    chaining::observer_pool _flows;

    void _setup_minus_button(ui_stepper_resource &);
    void _setup_plus_button(ui_stepper_resource &);
    void _setup_text(ui_stepper_resource &);
    void _setup_flows();

    void _update_text(int32_t const);
};
}  // namespace yas::vu
