//
//  vu_ui_indicator_container_presenter.mm
//

#include "vu_ui_indicator_container_presenter.hpp"
#include "vu_main.hpp"

using namespace yas;
using namespace yas::vu;

vu_ui_indicator_container_presenter::vu_ui_indicator_container_presenter(std::shared_ptr<main> const &main)
    : _weak_main(main) {
}

std::size_t vu_ui_indicator_container_presenter::indicator_count() const {
    if (auto const main = this->_weak_main.lock()) {
        return main->indicator_count();
    } else {
        return 0;
    }
}

observing::syncable vu_ui_indicator_container_presenter::observe_indicator_count(
    std::function<void(std::size_t const &)> &&handler) {
    if (auto const main = this->_weak_main.lock()) {
        return main->observe_indicator_count(std::move(handler));
    } else {
        return observing::syncable{};
    }
}

std::shared_ptr<vu_ui_indicator_container_presenter> vu_ui_indicator_container_presenter::make_shared(
    std::shared_ptr<main> const &main) {
    return std::shared_ptr<vu_ui_indicator_container_presenter>(new vu_ui_indicator_container_presenter{main});
}
