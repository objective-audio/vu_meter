//
//  vu_ui_main_presenter.mm
//

#include "vu_ui_main_presenter.hpp"
#include "vu_ui_color.hpp"

using namespace yas;
using namespace yas::vu;

ui_main_presenter::ui_main_presenter() {
}

ui::color const &ui_main_presenter::background_color() const {
    return vu::base_color();
}

std::shared_ptr<ui_main_presenter> ui_main_presenter::make_shared() {
    return std::shared_ptr<ui_main_presenter>(new ui_main_presenter{});
}
