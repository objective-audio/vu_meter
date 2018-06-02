//
//  vu_ui_reference.mm
//

#include "vu_ui_reference.hpp"
#include "vu_main.hpp"
#include "vu_ui_color.hpp"
#include "vu_ui_utils.hpp"
#include "yas_fast_each.h"
#include "yas_flow_utils.h"

using namespace yas;

namespace yas::vu {
static ui::uint_size constexpr reference_button_size{60, 60};
}

void vu::ui_stepper::setup(main_ptr_t &main, ui::texture &texture) {
    this->_setup_minus_button(texture);
    this->_setup_plus_button(texture);
    this->_setup_text(texture);
    this->_setup_data_flows(main);
    this->_setup_layout_flows();
}

void vu::ui_stepper::_setup_minus_button(ui::texture &texture) {
    ui::uint_size const button_size = vu::reference_button_size;

    this->minus_button = ui::button{ui::region::zero_centered(ui::to_size(button_size))};

    ui::node &minus_node = this->minus_button.rect_plane().node();
    minus_node.mesh().set_texture(texture);
    this->node.add_sub_node(minus_node);
    minus_node.attach_position_layout_guides(this->_minus_layout_guide_point);

    for (auto const is_tracking : {false, true}) {
        auto element =
            texture.add_draw_handler(button_size, vu::ui_utils::draw_button_handler(button_size, is_tracking, false));
        this->minus_button.rect_plane().data().observe_rect_tex_coords(element, to_rect_index(0, is_tracking));
    }
}

void vu::ui_stepper::_setup_plus_button(ui::texture &texture) {
    ui::uint_size const button_size = vu::reference_button_size;

    this->plus_button = ui::button{ui::region::zero_centered(ui::to_size(button_size))};

    ui::node &plus_node = this->plus_button.rect_plane().node();
    plus_node.mesh().set_texture(texture);
    this->node.add_sub_node(plus_node);
    plus_node.attach_position_layout_guides(this->_plus_layout_guide_point);

    for (auto const is_tracking : {false, true}) {
        auto element =
            texture.add_draw_handler(button_size, vu::ui_utils::draw_button_handler(button_size, is_tracking, true));
        this->plus_button.rect_plane().data().observe_rect_tex_coords(element, to_rect_index(0, is_tracking));
    }
}

void vu::ui_stepper::_setup_text(ui::texture &texture) {
    this->font_atlas = ui::font_atlas{
        {.font_name = "TrebuchetMS-Bold", .font_size = 24.0f, .words = "0123456789.dB-", .texture = texture}};

    this->text =
        ui::strings{{.max_word_count = 10, .font_atlas = this->font_atlas, .alignment = ui::layout_alignment::mid}};
    ui::node &text_node = this->text.rect_plane().node();
    this->node.add_sub_node(text_node);
    text_node.attach_position_layout_guides(this->_text_layout_guide_point);
    text_node.set_color(vu::setting_text_color());
}

void vu::ui_stepper::_setup_data_flows(main_ptr_t &main) {
    this->_minus_flow = this->minus_button.subject()
                            .begin_flow(ui::button::method::ended)
                            .receive_null(main->data.reference_decrement_receiver())
                            .end();

    this->_plus_flow = this->plus_button.subject()
                           .begin_flow(ui::button::method::ended)
                           .receive_null(main->data.reference_increment_receiver())
                           .end();

    this->_data_flow = main->data.begin_reference_flow()
                           .map([this](int32_t const &value) { return std::to_string(value) + " dB"; })
                           .receive(this->text.text_receiver())
                           .sync();
}

void vu::ui_stepper::_setup_layout_flows() {
    this->_flows.emplace_back(this->layout_guide_rect.left()
                                  .begin_flow()
                                  .combine(this->layout_guide_rect.right().begin_flow())
                                  .map(ui::justify())
                                  .receive(this->_center_guide_point.x().receiver())
                                  .sync());

    this->_flows.emplace_back(this->layout_guide_rect.top()
                                  .begin_flow()
                                  .combine(this->layout_guide_rect.bottom().begin_flow())
                                  .map(ui::justify())
                                  .receive(this->_center_guide_point.y().receiver())
                                  .sync());

    this->_flows.emplace_back(this->_center_guide_point.x()
                                  .begin_flow()
                                  .map(flow::add(-100.0f))
                                  .receive(this->_minus_layout_guide_point.x().receiver())
                                  .sync());
    this->_flows.emplace_back(
        this->_center_guide_point.y().begin_flow().receive(this->_minus_layout_guide_point.y().receiver()).sync());

    this->_flows.emplace_back(this->_center_guide_point.x()
                                  .begin_flow()
                                  .map(flow::add(100.0f))
                                  .receive(this->_plus_layout_guide_point.x().receiver())
                                  .sync());
    this->_flows.emplace_back(
        this->_center_guide_point.y().begin_flow().receive(this->_plus_layout_guide_point.y().receiver()).sync());

    float const text_distance = (this->font_atlas.ascent() + this->font_atlas.descent()) * 0.5;
    this->_flows.emplace_back(
        this->_center_guide_point.x().begin_flow().receive(this->_text_layout_guide_point.x().receiver()).sync());
    this->_flows.emplace_back(this->_center_guide_point.y()
                                  .begin_flow()
                                  .map(flow::add(text_distance))
                                  .receive(this->_text_layout_guide_point.y().receiver())
                                  .sync());
}

#pragma mark -

void vu::ui_reference::setup(main_ptr_t &main, ui::texture &texture) {
    this->_stepper.setup(main, texture);
}

ui::node &vu::ui_reference::node() {
    return this->_stepper.node;
}

ui::layout_guide_rect &vu::ui_reference::layout_guide_rect() {
    return this->_stepper.layout_guide_rect;
}
