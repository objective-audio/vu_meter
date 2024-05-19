//
//  vu_app_lifecycle.cpp
//

#include "app_lifecycle.hpp"

#include <cpp-utils/assertion.h>

#include <vu-meter-core/lifetimes/app/features/audio_graph.hpp>
#include <vu-meter-core/lifetimes/app/app_lifetime.hpp>

using namespace yas;
using namespace yas::vu;

std::shared_ptr<app_lifecycle> app_lifecycle::make_shared() {
    return std::make_shared<app_lifecycle>();
}

app_lifecycle::app_lifecycle() {
}

std::shared_ptr<app_lifetime> const &app_lifecycle::lifetime() const {
    return this->_lifetime;
}

void app_lifecycle::add_lifetime() {
    if (this->_lifetime) {
        assertion_failure_if_not_test();
        return;
    }

    this->_lifetime = app_lifetime::make_shared();
    this->_lifetime->audio_graph->setup();
}
