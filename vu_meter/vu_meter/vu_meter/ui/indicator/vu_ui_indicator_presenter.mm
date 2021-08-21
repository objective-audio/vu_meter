//
//  vu_ui_indicator_presenter.mm
//

#include "vu_ui_indicator_presenter.hpp"

#include "vu_app.h"
#include "vu_indicator.hpp"
#include "vu_main.hpp"
#include "vu_ui_indicator_constants.h"
#include "vu_ui_utils.hpp"

using namespace yas;
using namespace yas::vu;

ui_indicator_presenter::ui_indicator_presenter(std::shared_ptr<indicator> const &indicator, std::size_t const idx)
    : _weak_indicator(indicator), _idx(idx) {
}

ui::angle ui_indicator_presenter::meter_angle() const {
    if (auto indicator = this->_weak_indicator.lock()) {
        return ui_utils::meter_angle(indicator->value(), constants::half_angle.degrees);
    } else {
        return ui::angle::zero();
    }
}

std::string ui_indicator_presenter::ch_number_text() const {
    return "CH-" + std::to_string(this->_idx + 1);
}

std::shared_ptr<ui_indicator_presenter> ui_indicator_presenter::make_shared(std::size_t const idx) {
    auto const &app = vu::app::global();
    return std::shared_ptr<ui_indicator_presenter>(new ui_indicator_presenter{app->main->indicators().at(idx), idx});
}
