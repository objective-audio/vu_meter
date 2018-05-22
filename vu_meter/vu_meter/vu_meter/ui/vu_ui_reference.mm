//
//  vu_ui_reference.mm
//

#include "vu_ui_reference.hpp"
#include "vu_main.hpp"
#include "vu_ui_color.hpp"
#include "yas_fast_each.h"
#include "yas_flow_utils.h"

using namespace yas;

namespace yas::vu {
static ui::uint_size constexpr reference_button_size{60, 60};
}

void vu::ui_reference::setup(main_ptr_t &main, ui::texture &texture) {
    this->_setup_minus_button(main, texture);
    this->_setup_plus_button(main, texture);
    this->_setup_text(main, texture);
    this->_setup_layout();
}

void vu::ui_reference::_setup_minus_button(main_ptr_t &main, ui::texture &texture) {
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

    this->_minus_flow = this->minus_button.subject()
                            .begin_flow(ui::button::method::ended)
                            .to_null()
                            .end(main->data.reference_decrement_receiver());
}

void vu::ui_reference::_setup_plus_button(main_ptr_t &main, ui::texture &texture) {
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

    this->_plus_flow = this->plus_button.subject()
                           .begin_flow(ui::button::method::ended)
                           .to_null()
                           .end(main->data.reference_increment_receiver());
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

    this->_data_flow = main->data.begin_reference_flow()
                           .to([this](int32_t const &value) { return std::to_string(value) + " dB"; })
                           .sync(this->text.text_receiver());
}

void vu::ui_reference::_setup_layout() {
    this->_flows.emplace_back(ui::make_flow({.first_source_guide = this->layout_guide_rect.left(),
                                             .second_source_guide = this->layout_guide_rect.right(),
                                             .destination_guides = {this->_center_guide_point.x()}}));
    this->_flows.emplace_back(ui::make_flow({.first_source_guide = this->layout_guide_rect.top(),
                                             .second_source_guide = this->layout_guide_rect.bottom(),
                                             .destination_guides = {this->_center_guide_point.y()}}));

    this->_flows.emplace_back(this->_center_guide_point.x()
                                  .begin_flow()
                                  .to(flow::add(-100.0f))
                                  .sync(this->_minus_layout_guide_point.x().receiver()));
    this->_flows.emplace_back(
        this->_center_guide_point.y().begin_flow().sync(this->_minus_layout_guide_point.y().receiver()));

    this->_flows.emplace_back(this->_center_guide_point.x()
                                  .begin_flow()
                                  .to(flow::add(100.0f))
                                  .sync(this->_plus_layout_guide_point.x().receiver()));
    this->_flows.emplace_back(
        this->_center_guide_point.y().begin_flow().sync(this->_plus_layout_guide_point.y().receiver()));

    float const text_distance = (this->font_atlas.ascent() + this->font_atlas.descent()) * 0.5;
    this->_flows.emplace_back(
        this->_center_guide_point.x().begin_flow().sync(this->_text_layout_guide_point.x().receiver()));
    this->_flows.emplace_back(this->_center_guide_point.y()
                                  .begin_flow()
                                  .to(flow::add(text_distance))
                                  .sync(this->_text_layout_guide_point.y().receiver()));
}
