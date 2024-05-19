//
//  vu_ui_main_lifetime.cpp
//

#include "vu_ui_main_lifetime.hpp"
#include <vu-meter-core/lifetimes/ui_main/features/vu_ui_background.hpp>
#include <vu-meter-core/lifetimes/ui_main/features/vu_ui_indicator_layout.hpp>
#include <vu-meter-core/lifetimes/ui_main/features/vu_ui_indicator_resource.hpp>
#include <vu-meter-core/lifetimes/ui_main/features/vu_ui_indicators.hpp>
#include <vu-meter-core/lifetimes/ui_main/lifecycles/vu_ui_indicator_lifecycle.hpp>

using namespace yas;
using namespace yas::vu;

std::shared_ptr<ui_main_lifetime> ui_main_lifetime::make_shared() {
    return std::make_shared<ui_main_lifetime>();
}

ui_main_lifetime::ui_main_lifetime()
    : background(ui_background::make_shared()),
      indicator_resource(ui_indicator_resource::make_shared()),
      indicator_layout(ui_indicator_layout::make_shared(this->indicator_resource.get())),
      indicator_lifecycle(ui_indicator_lifecycle::make_shared()),
      indicators(ui_indicators::make_shared(this->indicator_lifecycle.get())) {
}
