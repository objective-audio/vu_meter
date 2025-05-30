//
//  vu_ui_indicator_presenter.mm
//

#include "ui_indicator_presenter.hpp"

#include <vu-meter-core/lifetimes/ui_indicator/features/ui_indicator_constants.h>
#include <vu-meter-core/lifetimes/app/features/audio_graph.hpp>
#include <vu-meter-core/lifetimes/global/lifetime_accessor.hpp>
#include <vu-meter-core/lifetimes/indicator/features/indicator.hpp>
#include <vu-meter-core/lifetimes/indicator/indicator_lifetime.hpp>
#include <vu-meter-core/ui/utils/ui_utils.hpp>

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
    auto const &indicator_lifetime = lifetime_accessor::indicator_lifetime(idx);
    return std::shared_ptr<ui_indicator_presenter>(new ui_indicator_presenter{indicator_lifetime->indicator, idx});
}
