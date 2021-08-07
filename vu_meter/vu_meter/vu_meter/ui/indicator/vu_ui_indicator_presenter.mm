//
//  vu_ui_indicator_presenter.mm
//

#include "vu_ui_indicator_presenter.hpp"

#include "vu_main.hpp"
#include "vu_ui_indicator_constants.h"
#include "vu_ui_utils.hpp"

using namespace yas;
using namespace yas::vu;

ui_indicator_presenter::ui_indicator_presenter(std::shared_ptr<main> const &main, std::size_t const idx)
    : _weak_main(main), _idx(idx) {
}

ui::angle ui_indicator_presenter::meter_angle() const {
    if (auto main = this->_weak_main.lock()) {
        auto values = main->values();
        float const value = (this->_idx < values.size()) ? values.at(this->_idx) : 0.0f;
        return ui_utils::meter_angle(value, main->settings->reference(), constants::half_angle.degrees);
    } else {
        return ui::angle::zero();
    }
}

std::string ui_indicator_presenter::ch_number_text() const {
    return "CH-" + std::to_string(this->_idx + 1);
}

std::shared_ptr<ui_indicator_presenter> ui_indicator_presenter::make_shared(std::shared_ptr<main> const &main,
                                                                            std::size_t const idx) {
    return std::shared_ptr<ui_indicator_presenter>(new ui_indicator_presenter{main, idx});
}
