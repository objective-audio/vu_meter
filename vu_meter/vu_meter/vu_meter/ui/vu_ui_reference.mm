//
//  vu_ui_reference.mm
//

#include "vu_ui_reference.hpp"
#include "vu_main.hpp"
#include "yas_fast_each.h"
#include "vu_ui_color.hpp"

using namespace yas;

namespace yas::vu {
static ui::uint_size constexpr reference_button_size{60, 60};
}

void vu::ui_reference::setup(main_ptr_t &main, ui::texture &texture) {
    weak_main_ptr_t weak_main = main;

    this->_setup_minus_button(weak_main, texture);
    this->_setup_plus_button(weak_main, texture);
    this->_setup_text(main, texture);
    this->_setup_layout();

    // update ui

    this->_update_ui(main->data.reference());
}

void vu::ui_reference::_setup_minus_button(weak_main_ptr_t &weak_main, ui::texture &texture) {
    ui::uint_size const button_size = vu::reference_button_size;

    ui::node &minus_node = this->minus_button.rect_plane().node();
    minus_node.mesh().set_texture(texture);
    this->node.add_sub_node(minus_node);
    minus_node.attach_position_layout_guides(this->_minus_layout_guide_point);
    minus_node.set_color(vu::reference_button_color());

    for (auto const is_tracking : {false, true}) {
        auto draw_handler = [button_size, is_tracking](CGContextRef const ctx) {
            CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(ctx, CGRectMake(0.0, 0.0, button_size.width, button_size.height));
        };
        auto element = texture.add_draw_handler(button_size, std::move(draw_handler));
        this->minus_button.rect_plane().data().observe_rect_tex_coords(element, to_rect_index(0, is_tracking));
    }

    auto minus_observer =
        this->minus_button.subject().make_observer(ui::button::method::ended, [weak_main](auto const &context) {
            if (auto main = weak_main.lock()) {
                main->data.decrement_reference();
            }
        });

    this->_button_observers.emplace_back(std::move(minus_observer));
}

void vu::ui_reference::_setup_plus_button(weak_main_ptr_t &weak_main, ui::texture &texture) {
    ui::uint_size const button_size = vu::reference_button_size;

    ui::node &plus_node = this->plus_button.rect_plane().node();
    plus_node.mesh().set_texture(texture);
    this->node.add_sub_node(plus_node);
    plus_node.attach_position_layout_guides(this->_plus_layout_guide_point);
    plus_node.set_color(vu::reference_button_color());

    for (auto const is_tracking : {false, true}) {
        auto draw_handler = [button_size, is_tracking](CGContextRef const ctx) {
            CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(ctx, CGRectMake(0.0, 0.0, button_size.width, button_size.height));
        };
        auto element = texture.add_draw_handler(button_size, std::move(draw_handler));
        this->plus_button.rect_plane().data().observe_rect_tex_coords(element, to_rect_index(0, is_tracking));
    }

    auto plus_observer =
        this->plus_button.subject().make_observer(ui::button::method::ended, [weak_main](auto const &context) {
            if (auto main = weak_main.lock()) {
                main->data.increment_reference();
            }
        });

    this->_button_observers.emplace_back(std::move(plus_observer));
}

void vu::ui_reference::_setup_text(main_ptr_t &main, ui::texture &texture) {
    this->font_atlas = ui::font_atlas{
        {.font_name = "TrebuchetMS-Bold", .font_size = 24.0f, .words = "0123456789.dB-", .texture = texture}};

    this->text =
        ui::strings{{.max_word_count = 10, .font_atlas = this->font_atlas, .alignment = ui::layout_alignment::mid}};
    ui::node &text_node = this->text.rect_plane().node();
    this->node.add_sub_node(text_node);
    text_node.attach_position_layout_guides(this->_text_layout_guide_point);
    text_node.set_color(vu::reference_text_color());

    this->_data_observer =
        main->data.subject.make_observer(vu::data::method::reference_changed, [this](auto const &context) {
            vu::data const &data = context.value;
            this->_update_ui(data.reference());
        });
}

void vu::ui_reference::_setup_layout() {
    ui::layout_guide center_x_guide;
    ui::layout_guide center_y_guide;

    this->_layouts.emplace_back(
        ui::make_layout({.first_source_guide = this->layout_guide_rect.left(),
                         .second_source_guide = this->layout_guide_rect.right(),
                         .destination_guides = {ui::layout_guide{}, center_x_guide, ui::layout_guide{}}}));
    this->_layouts.emplace_back(
        ui::make_layout({.first_source_guide = this->layout_guide_rect.top(),
                         .second_source_guide = this->layout_guide_rect.bottom(),
                         .destination_guides = {ui::layout_guide{}, center_y_guide, ui::layout_guide{}}}));

    this->_layouts.emplace_back(ui::make_layout(
        {.source_guide = center_x_guide, .destination_guide = this->_minus_layout_guide_point.x(), .distance = -100}));
    this->_layouts.emplace_back(
        ui::make_layout({.source_guide = center_y_guide, .destination_guide = this->_minus_layout_guide_point.y()}));

    this->_layouts.emplace_back(ui::make_layout(
        {.source_guide = center_x_guide, .destination_guide = this->_plus_layout_guide_point.x(), .distance = 100}));
    this->_layouts.emplace_back(
        ui::make_layout({.source_guide = center_y_guide, .destination_guide = this->_plus_layout_guide_point.y()}));

    float const text_distance = (this->font_atlas.ascent() + this->font_atlas.descent()) * 0.5;
    this->_layouts.emplace_back(
        ui::make_layout({.source_guide = center_x_guide, .destination_guide = this->_text_layout_guide_point.x()}));
    this->_layouts.emplace_back(ui::make_layout({.source_guide = center_y_guide,
                                                 .destination_guide = this->_text_layout_guide_point.y(),
                                                 .distance = text_distance}));
}

void vu::ui_reference::_update_ui(int32_t const ref) {
    this->text.set_text(std::to_string(ref) + " dB");
}
