//
//  vu_indicator_values.cpp
//

#include "indicator_values.hpp"

#include <cpp-utils/fast_each.h>

#include <vu-meter-core/lifetimes/app/lifecycles/indicator_lifecycle.hpp>
#include <vu-meter-core/lifetimes/app/value_types/indicator_value.hpp>

using namespace yas;
using namespace yas::vu;

std::shared_ptr<indicator_values> indicator_values::make_shared(indicator_lifecycle *lifecycle) {
    return std::make_shared<indicator_values>(lifecycle);
}

indicator_values::indicator_values(indicator_lifecycle *lifecycle) : _lifecycle(lifecycle) {
}

std::vector<std::shared_ptr<indicator_value>> const &indicator_values::raw() const {
    return this->_raw;
}

void indicator_values::resize(std::size_t const size) {
    if (this->_raw.size() == size) {
        return;
    }

    this->_raw.clear();

    auto each = make_fast_each(size);
    while (yas_each_next(each)) {
        this->_raw.emplace_back(indicator_value::make_shared());
    }

    this->_lifecycle->reload(this->_raw);
}
