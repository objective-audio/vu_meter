//
//  vu_data.hpp
//

#pragma once

#include <stdint.h>
#include "yas_base.h"
#include "yas_observing.h"
#include "yas_flow.h"
#include "yas_property.h"

namespace yas::vu {
struct data : base {
    struct impl;

    enum class method { reference_changed };

    using subject_t = subject<method, data>;
    using observer_t = subject_t::observer_t;

    data();
    data(std::nullptr_t);

    property<std::nullptr_t, int32_t> &reference();
    property<std::nullptr_t, int32_t> const &reference() const;
    void increment_reference();
    void decrement_reference();
};
}
