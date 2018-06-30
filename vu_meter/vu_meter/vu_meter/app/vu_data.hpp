//
//  vu_data.hpp
//

#pragma once

#include <stdint.h>
#include "yas_base.h"
#include "yas_flow.h"

namespace yas::vu {
struct data : base {
    struct impl;

    data();
    data(std::nullptr_t);

    void set_reference(int32_t const);
    int32_t reference() const;

    flow::node_t<int32_t, true> begin_reference_flow() const;
    flow::node_t<bool, true> begin_is_reference_max_flow() const;
    flow::node_t<bool, true> begin_is_reference_min_flow() const;
    flow::receiver<> &reference_increment_receiver();
    flow::receiver<> &reference_decrement_receiver();
};
}  // namespace yas::vu
