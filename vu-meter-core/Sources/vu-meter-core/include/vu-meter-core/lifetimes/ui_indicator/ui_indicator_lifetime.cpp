//
//  vu_ui_indicator_lifetime.cpp
//

#include "ui_indicator_lifetime.hpp"

#include <vu-meter-core/lifetimes/ui_indicator/features/ui_indicator.hpp>

using namespace yas;
using namespace yas::vu;

std::shared_ptr<ui_indicator_lifetime> ui_indicator_lifetime::make_shared(std::size_t const idx) {
    return std::make_shared<ui_indicator_lifetime>(idx);
}

ui_indicator_lifetime::ui_indicator_lifetime(std::size_t const idx) : indicator(ui_indicator::make_shared(idx)) {
}
