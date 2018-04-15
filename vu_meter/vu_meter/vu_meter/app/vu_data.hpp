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

    void set_reference(int32_t const);
    void increment_reference();
    void decrement_reference();
    int32_t reference() const;

    subject_t &subject();
};
}
