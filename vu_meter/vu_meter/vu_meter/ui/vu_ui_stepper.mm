//
//  vu_ui_stepper.mm
//

#include "vu_ui_stepper.hpp"
#include <chaining/yas_chaining_utils.h>
#include "vu_ui_color.hpp"
#include "vu_ui_utils.hpp"

using namespace yas;

namespace yas::vu {
static ui::uint_size constexpr reference_button_size{60, 60};
}

#pragma mark - ui_stepper_resource

struct vu::ui_stepper_resource::impl : base::impl {
    ui::texture _texture;
    std::vector<ui::texture_element> _minus_elements;
    std::vector<ui::texture_element> _plus_elements;
    ui::font_atlas _font_atlas;

    impl(ui::texture &texture)
        : _texture(texture),
          _font_atlas(
              {.font_name = "TrebuchetMS-Bold", .font_size = 24.0f, .words = "0123456789.dB-", .texture = texture}) {
        ui::uint_size const button_size = vu::reference_button_size;

        for (auto const is_tracking : {false, true}) {
            this->_minus_elements.emplace_back(texture.add_draw_handler(
                button_size, vu::ui_utils::draw_button_handler(button_size, is_tracking, false)));
            this->_plus_elements.emplace_back(texture.add_draw_handler(
                button_size, vu::ui_utils::draw_button_handler(button_size, is_tracking, true)));
        }
    }
};

vu::ui_stepper_resource::ui_stepper_resource(ui::texture &texture) : base(std::make_shared<impl>(texture)) {
}

vu::ui_stepper_resource::ui_stepper_resource(std::nullptr_t) : base(nullptr) {
}

ui ::texture &vu::ui_stepper_resource::texture() {
    return impl_ptr<impl>()->_texture;
}

std::vector<ui::texture_element> &vu::ui_stepper_resource::minus_elements() {
    return impl_ptr<impl>()->_minus_elements;
}

std::vector<ui::texture_element> &vu::ui_stepper_resource::plus_elements() {
    return impl_ptr<impl>()->_plus_elements;
}

ui::font_atlas const &vu::ui_stepper_resource::font_atlas() {
    return impl_ptr<impl>()->_font_atlas;
}

#pragma mark - ui_stepper

void vu::ui_stepper::setup(ui_stepper_resource &resource) {
    this->_setup_minus_button(resource);
    this->_setup_plus_button(resource);
    this->_setup_text(resource);
    this->_setup_chainings();
}

void vu::ui_stepper::_setup_minus_button(ui_stepper_resource &resource) {
    ui::uint_size const button_size = vu::reference_button_size;

    this->_minus_button = ui::button{ui::region::zero_centered(ui::to_size(button_size))};

    ui::node &minus_node = this->_minus_button.rect_plane().node();
    minus_node.mesh().raw().set_texture(resource.texture());
    this->node.add_sub_node(minus_node);
    minus_node.attach_position_layout_guides(this->_minus_layout_guide_point);

    for (auto const is_tracking : {false, true}) {
        auto const idx = to_rect_index(0, is_tracking);
        this->_minus_button.rect_plane().data().observe_rect_tex_coords(resource.minus_elements().at(idx), idx);
    }
}

void vu::ui_stepper::_setup_plus_button(ui_stepper_resource &resource) {
    ui::uint_size const button_size = vu::reference_button_size;

    this->_plus_button = ui::button{ui::region::zero_centered(ui::to_size(button_size))};

    ui::node &plus_node = this->_plus_button.rect_plane().node();
    plus_node.mesh().raw().set_texture(resource.texture());
    this->node.add_sub_node(plus_node);
    plus_node.attach_position_layout_guides(this->_plus_layout_guide_point);

    for (auto const is_tracking : {false, true}) {
        auto const idx = to_rect_index(0, is_tracking);
        this->_plus_button.rect_plane().data().observe_rect_tex_coords(resource.plus_elements().at(idx), idx);
    }
}

void vu::ui_stepper::_setup_text(ui_stepper_resource &resource) {
    this->_font_atlas = resource.font_atlas();

    this->_text =
        ui::strings{{.max_word_count = 10, .font_atlas = this->_font_atlas, .alignment = ui::layout_alignment::mid}};
    ui::node &text_node = this->_text.rect_plane().node();
    this->node.add_sub_node(text_node);
    text_node.attach_position_layout_guides(this->_text_layout_guide_point);
    text_node.color().set_value(vu::setting_text_color());
}

void vu::ui_stepper::_setup_chainings() {
    this->_observers += this->_minus_enabled_setter.chain()
                            .perform([this](bool const &value) {
                                if (!value) {
                                    this->_minus_button.cancel_tracking();
                                }
                            })
                            .receive(this->_minus_button.rect_plane().node().collider().raw().enabled_receiver())
                            .end();

    this->_observers += this->_plus_enabled_setter.chain()
                            .perform([this](bool const &value) {
                                if (!value) {
                                    this->_plus_button.cancel_tracking();
                                }
                            })
                            .receive(this->_plus_button.rect_plane().node().collider().raw().enabled_receiver())
                            .end();

    this->_observers += this->layout_guide_rect.left()
                            .chain()
                            .combine(this->layout_guide_rect.right().chain())
                            .to(ui::justify())
                            .receive(this->_center_guide_point.x().receiver())
                            .sync();

    this->_observers += this->layout_guide_rect.top()
                            .chain()
                            .combine(this->layout_guide_rect.bottom().chain())
                            .to(ui::justify())
                            .receive(this->_center_guide_point.y().receiver())
                            .sync();

    this->_observers += this->layout_guide_rect.left()
                            .chain()
                            .to(chaining::add(static_cast<float>(vu::reference_button_size.width / 2)))
                            .receive(this->_minus_layout_guide_point.x().receiver())
                            .sync();
    this->_observers +=
        this->_center_guide_point.y().chain().receive(this->_minus_layout_guide_point.y().receiver()).sync();

    this->_observers += this->layout_guide_rect.right()
                            .chain()
                            .to(chaining::add(-static_cast<float>(vu::reference_button_size.width / 2)))
                            .receive(this->_plus_layout_guide_point.x().receiver())
                            .sync();
    this->_observers +=
        this->_center_guide_point.y().chain().receive(this->_plus_layout_guide_point.y().receiver()).sync();

    float const text_distance = (this->_font_atlas.ascent() + this->_font_atlas.descent()) * 0.5;
    this->_observers +=
        this->_center_guide_point.x().chain().receive(this->_text_layout_guide_point.x().receiver()).sync();
    this->_observers += this->_center_guide_point.y()
                            .chain()
                            .to(chaining::add(text_distance))
                            .receive(this->_text_layout_guide_point.y().receiver())
                            .sync();
}

vu::ui_stepper::button_chain_t vu::ui_stepper::minus_chain() {
    return this->_minus_button.chain(ui::button::method::ended);
}

vu::ui_stepper::button_chain_t vu::ui_stepper::plus_chain() {
    return this->_plus_button.chain(ui::button::method::ended);
}

chaining::receiver<std::string> &vu::ui_stepper::text_receiver() {
    return this->_text.text_receiver();
}

chaining::receiver<bool> &vu::ui_stepper::minus_enabled_receiver() {
    return this->_minus_enabled_setter.receiver();
}

chaining::receiver<bool> &vu::ui_stepper::plus_enabled_receiver() {
    return this->_plus_enabled_setter.receiver();
}
