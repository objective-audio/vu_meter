//
//  vu_data.hpp
//

#pragma once

#include <chaining/yas_chaining_umbrella.h>
#include <cpp_utils/yas_base.h>
#include <stdint.h>

namespace yas::vu {
struct data : base {
    struct impl;

    data();
    data(std::nullptr_t);

    flow::property<int32_t> &reference();

    flow::node_t<bool, true> begin_is_reference_max_flow() const;
    flow::node_t<bool, true> begin_is_reference_min_flow() const;
    flow::receiver<> &reference_increment_receiver();
    flow::receiver<> &reference_decrement_receiver();
};
}  // namespace yas::vu
