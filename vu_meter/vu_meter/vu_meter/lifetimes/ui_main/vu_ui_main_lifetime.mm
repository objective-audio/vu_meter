//
//  vu_ui_main_lifetime.cpp
//

#include "vu_ui_main_lifetime.hpp"
#include "vu_ui_background.hpp"
#include "vu_ui_indicator_container.hpp"
#include "vu_ui_indicator_factory.hpp"
#include "vu_ui_indicator_resource.hpp"

using namespace yas;
using namespace yas::vu;

std::shared_ptr<ui_main_lifetime> ui_main_lifetime::make_shared() {
    return std::make_shared<ui_main_lifetime>();
}

ui_main_lifetime::ui_main_lifetime()
    : background(ui_background::make_shared()),
      indicator_resource(ui_indicator_resource::make_shared()),
      indicator_factory(ui_indicator_factory::make_shared()),
      indicator_container(ui_indicator_container::make_shared(this->indicator_factory, this->indicator_resource)) {
}
