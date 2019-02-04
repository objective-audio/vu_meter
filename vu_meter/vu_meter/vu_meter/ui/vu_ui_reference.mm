//
//  vu_ui_reference.mm
//

#include "vu_ui_reference.hpp"
#include "vu_data.hpp"
#include "vu_main.hpp"

using namespace yas;

#pragma mark -

void vu::ui_reference::setup(main_ptr_t &main, ui_stepper_resource &resource) {
    this->_stepper.setup(resource);
    this->_setup_chainings(main);
}

void vu::ui_reference::_setup_chainings(main_ptr_t &main) {
    this->_observers += this->_stepper.minus_chain().receive_null(main->data.reference_decrement_receiver()).end();

    this->_observers += this->_stepper.plus_chain().receive_null(main->data.reference_increment_receiver()).end();

    this->_observers += main->data.reference()
                            .chain()
                            .to([this](int32_t const &value) { return std::to_string(value) + " dB"; })
                            .receive(this->_stepper.text_receiver())
                            .sync();

    this->_observers += main->data.is_reference_max_chain()
                            .to([](bool const &value) { return !value; })
                            .receive(this->_stepper.plus_enabled_receiver())
                            .sync();

    this->_observers += main->data.is_reference_min_chain()
                            .to([](bool const &value) { return !value; })
                            .receive(this->_stepper.minus_enabled_receiver())
                            .sync();
}

ui::node &vu::ui_reference::node() {
    return this->_stepper.node;
}

ui::layout_guide_rect &vu::ui_reference::layout_guide_rect() {
    return this->_stepper.layout_guide_rect;
}
