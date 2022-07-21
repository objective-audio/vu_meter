//
//  vu_ui_indicators.cpp
//

#include "vu_ui_indicators.hpp"

#include "vu_app_lifetime.hpp"
#include "vu_indicator_lifecycle.hpp"
#include "vu_lifetime_accessor.hpp"
#include "vu_ui_indicator_lifecycle.hpp"

using namespace yas;
using namespace yas::vu;

std::shared_ptr<ui_indicators> ui_indicators::make_shared(ui_indicator_lifecycle *ui_lifecycle) {
    auto const &app_lifetime = lifetime_accessor::app_lifetime();
    return std::make_shared<ui_indicators>(app_lifetime->indicator_lifecycle.get(), ui_lifecycle);
}

ui_indicators::ui_indicators(indicator_lifecycle *source_lifecycle, ui_indicator_lifecycle *lifecycle)
    : _source_lifecycle(source_lifecycle), _ui_lifecycle(lifecycle) {
}

void ui_indicators::setup() {
    this->_source_lifecycle->observe([this](auto const &lifetimes) { this->_ui_lifecycle->reload(lifetimes.size()); })
        .sync()
        ->add_to(this->_pool);
}
