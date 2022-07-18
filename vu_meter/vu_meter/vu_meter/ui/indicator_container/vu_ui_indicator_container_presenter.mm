//
//  vu_ui_indicator_container_presenter.mm
//

#include "vu_ui_indicator_container_presenter.hpp"
#include "vu_app_lifetime.hpp"
#include "vu_indicator_lifecycle.hpp"
#include "vu_lifetime_accessor.hpp"

using namespace yas;
using namespace yas::vu;

std::shared_ptr<vu_ui_indicator_container_presenter> vu_ui_indicator_container_presenter::make_shared() {
    auto const &app_lifetime = lifetime_accessor::app_lifetime();
    return std::shared_ptr<vu_ui_indicator_container_presenter>(
        new vu_ui_indicator_container_presenter{app_lifetime->indicator_lifecycle});
}

vu_ui_indicator_container_presenter::vu_ui_indicator_container_presenter(
    std::shared_ptr<indicator_lifecycle> const &lifecycle)
    : _indicator_count(observing::value::holder<std::size_t>::make_shared(0)) {
    lifecycle->observe([this](auto const &lifetimes) { this->_indicator_count->set_value(lifetimes.size()); })
        .sync()
        ->add_to(this->_pool);
}

std::size_t vu_ui_indicator_container_presenter::indicator_count() const {
    return this->_indicator_count->value();
}

observing::syncable vu_ui_indicator_container_presenter::observe_indicator_count(
    std::function<void(std::size_t const &)> &&handler) {
    return this->_indicator_count->observe(std::move(handler));
}
