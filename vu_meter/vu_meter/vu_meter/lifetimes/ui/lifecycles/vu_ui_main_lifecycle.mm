//
//  vu_ui_main_lifecycle.cpp
//

#include "vu_ui_main_lifecycle.hpp"

#include <cpp_utils/yas_assertion.h>

#include "vu_ui_indicator_container.hpp"
#include "vu_ui_main_lifetime.hpp"

using namespace yas;
using namespace yas::vu;

std::shared_ptr<ui_main_lifecycle> ui_main_lifecycle::make_shared() {
    return std::make_shared<ui_main_lifecycle>();
}

std::shared_ptr<ui_main_lifetime> const &ui_main_lifecycle::lifetime() const {
    return this->_lifetime;
}

void ui_main_lifecycle::add_lifetime() {
    if (this->_lifetime) {
        assertion_failure_if_not_test();
        return;
    }

    this->_lifetime = ui_main_lifetime::make_shared();
    this->_lifetime->indicator_container->setup();
}
