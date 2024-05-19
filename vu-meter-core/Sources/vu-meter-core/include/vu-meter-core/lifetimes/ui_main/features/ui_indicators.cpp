//
//  vu_ui_indicators.cpp
//

#include "ui_indicators.hpp"

#include <vu-meter-core/lifetimes/app/lifecycles/indicator_lifecycle.hpp>
#include <vu-meter-core/lifetimes/app/app_lifetime.hpp>
#include <vu-meter-core/lifetimes/global/lifetime_accessor.hpp>
#include <vu-meter-core/lifetimes/ui_main/lifecycles/ui_indicator_lifecycle.hpp>

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
