//
//  vu_ui_main_factories.cpp
//

#include "vu_ui_main_factories.hpp"
#include "vu_app.h"
#include "vu_ui_indicator.hpp"

using namespace yas;
using namespace yas::vu;

ui_main_indicator_factory::ui_main_indicator_factory(std::shared_ptr<ui_indicator_resource> const &resource)
    : _resource(resource) {
}

std::shared_ptr<ui_indicator> ui_main_indicator_factory::make_indicator(std::size_t const idx) {
    auto const &app = vu::app::shared();
    auto const presenter = ui_indicator_presenter::make_shared(app->main, idx);
    return ui_indicator::make_shared(app->ui_standard, this->_resource, presenter);
}

std::shared_ptr<ui_main_indicator_factory> ui_main_indicator_factory::make_shared(
    std::shared_ptr<ui_indicator_resource> const &resource) {
    return std::shared_ptr<ui_main_indicator_factory>(new ui_main_indicator_factory{resource});
}