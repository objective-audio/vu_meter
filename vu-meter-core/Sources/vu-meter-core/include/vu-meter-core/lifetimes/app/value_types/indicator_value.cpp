//
//  vu_indicator_value.cpp
//

#include "indicator_value.hpp"

using namespace yas;
using namespace yas::vu;

std::shared_ptr<indicator_value> indicator_value::make_shared() {
    return std::make_shared<indicator_value>();
}

void indicator_value::store(float const value) {
    this->_raw_value.store(value);
}

[[nodiscard]] float indicator_value::load() const {
    return this->_raw_value.load();
}
