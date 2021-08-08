//
//  vu_ui_main_factories.cpp
//

#include "vu_ui_indicator_factory.hpp"
#include "vu_app.h"
#include "vu_ui_indicator.hpp"

using namespace yas;
using namespace yas::vu;

ui_indicator_factory::ui_indicator_factory(std::shared_ptr<ui_indicator_resource> const &resource)
    : _resource(resource) {
}

std::shared_ptr<ui_indicator_container_indicator_interface> ui_indicator_factory::make_indicator(
    std::size_t const idx) {
    return ui_indicator::make_shared(this->_resource, idx);
}

std::shared_ptr<ui_indicator_factory> ui_indicator_factory::make_shared(
    std::shared_ptr<ui_indicator_resource> const &resource) {
    return std::shared_ptr<ui_indicator_factory>(new ui_indicator_factory{resource});
}
