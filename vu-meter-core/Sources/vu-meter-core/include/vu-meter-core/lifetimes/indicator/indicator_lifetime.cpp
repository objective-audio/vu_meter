//
//  vu_indicator_lifetime.cpp
//

#include "indicator_lifetime.hpp"

#include <vu-meter-core/lifetimes/app/features/settings.hpp>
#include <vu-meter-core/lifetimes/app/app_lifetime.hpp>
#include <vu-meter-core/lifetimes/global/lifetime_accessor.hpp>
#include <vu-meter-core/lifetimes/indicator/features/indicator.hpp>

using namespace yas;
using namespace yas::vu;

std::shared_ptr<indicator_lifetime> indicator_lifetime::make_shared(std::shared_ptr<indicator_value> const &value) {
    auto const &app_lifetime = lifetime_accessor::app_lifetime();
    return std::make_shared<indicator_lifetime>(value, app_lifetime);
}

indicator_lifetime::indicator_lifetime(std::shared_ptr<indicator_value> const &value,
                                       std::shared_ptr<app_lifetime> const &app_lifetime)
    : indicator(vu::indicator::make_shared(value, app_lifetime->settings)) {
}
