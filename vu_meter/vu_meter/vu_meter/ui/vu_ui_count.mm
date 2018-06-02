//
//  vu_ui_count.mm
//

#include "vu_ui_count.hpp"
#include "vu_data.hpp"
#include "vu_main.hpp"

using namespace yas;

void vu::ui_count::setup(main_ptr_t &main, ui::texture &texture) {
    this->_stepper.setup(texture);
    this->_setup_flows(main);
}

void vu::ui_count::_setup_flows(main_ptr_t &main) {
    this->_flows.emplace_back(
        this->_stepper.begin_minus_flow().receive_null(main->data.indicator_count_decrement_receiver()).end());

    this->_flows.emplace_back(
        this->_stepper.begin_plus_flow().receive_null(main->data.indicator_count_increment_receiver()).end());

    this->_flows.emplace_back(main->data.begin_indicator_count_flow()
                                  .map([this](uint32_t const &value) { return std::to_string(value); })
                                  .receive(this->_stepper.text_receiver())
                                  .sync());

    this->_flows.emplace_back(main->data.begin_is_indicator_count_max_flow()
                                  .map([](bool const &value) { return !value; })
                                  .receive(this->_stepper.plus_enabled_receiver())
                                  .sync());

    this->_flows.emplace_back(main->data.begin_is_indicator_count_min_flow()
                                  .map([](bool const &value) { return !value; })
                                  .receive(this->_stepper.minus_enabled_receiver())
                                  .sync());
}

ui::node &vu::ui_count::node() {
    return this->_stepper.node;
}

ui::layout_guide_rect &vu::ui_count::layout_guide_rect() {
    return this->_stepper.layout_guide_rect;
}
