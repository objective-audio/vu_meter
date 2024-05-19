//
//  vu_ui_lifecycle.cpp
//

#include "ui_lifecycle.hpp"

#include <cpp-utils/assertion.h>

#include <vu-meter-core/lifetimes/ui/lifecycles/ui_main_lifecycle.hpp>
#include <vu-meter-core/lifetimes/ui/ui_lifetime.hpp>

using namespace yas;
using namespace yas::vu;

std::shared_ptr<ui_lifecycle> ui_lifecycle::make_shared() {
    return std::make_shared<ui_lifecycle>();
}

ui_lifecycle::ui_lifecycle() {
}

std::shared_ptr<ui_lifetime> const &ui_lifecycle::lifetime() const {
    return this->_lifetime;
}

void ui_lifecycle::add_lifetime(std::shared_ptr<ui::standard> const &standard) {
    if (this->_lifetime) {
        assertion_failure_if_not_test();
        return;
    }

    this->_lifetime = ui_lifetime::make_shared(standard);
    this->_lifetime->main_lifecycle->add_lifetime();
}
