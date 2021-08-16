//
//  vu_ui_indicator_container_presenter.mm
//

#include "vu_ui_indicator_container_presenter.hpp"
#include "vu_app.h"
#include "vu_main.hpp"

using namespace yas;
using namespace yas::vu;

vu_ui_indicator_container_presenter::vu_ui_indicator_container_presenter(std::shared_ptr<main> const &main)
    : _indicator_count(observing::value::holder<std::size_t>::make_shared(0)) {
    main->observe_indicators([this](auto const &indicators) { this->_indicator_count->set_value(indicators.size()); })
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

std::shared_ptr<vu_ui_indicator_container_presenter> vu_ui_indicator_container_presenter::make_shared() {
    auto const &main = app::shared()->main;
    return std::shared_ptr<vu_ui_indicator_container_presenter>(new vu_ui_indicator_container_presenter{main});
}
