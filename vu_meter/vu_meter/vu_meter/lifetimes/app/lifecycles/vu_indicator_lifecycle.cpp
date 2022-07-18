//
//  vu_indicator_lifecycle.cpp
//

#include "vu_indicator_lifecycle.hpp"

#include <cpp_utils/yas_fast_each.h>

#include "vu_indicator_lifetime.hpp"

using namespace yas;
using namespace yas::vu;

std::shared_ptr<indicator_lifecycle> indicator_lifecycle::make_shared() {
    return std::make_shared<indicator_lifecycle>();
}

indicator_lifecycle::indicator_lifecycle()
    : _lifetimes(observing::value::holder<indicator_lifetimes>::make_shared({})) {
}

std::vector<std::shared_ptr<indicator_lifetime>> const &indicator_lifecycle::lifetimes() const {
    return this->_lifetimes->value();
}

void indicator_lifecycle::reload(std::vector<std::shared_ptr<indicator_value>> const &values) {
    this->_lifetimes->set_value({});

    indicator_lifetimes lifetimes;

    auto each = make_fast_each(values.size());
    while (yas_each_next(each)) {
        auto const &idx = yas_each_index(each);
        lifetimes.emplace_back(indicator_lifetime::make_shared(values.at(idx)));
    }

    this->_lifetimes->set_value(std::move(lifetimes));
}

observing::syncable indicator_lifecycle::observe(std::function<void(indicator_lifetimes const &)> &&handler) {
    return this->_lifetimes->observe(std::move(handler));
}
