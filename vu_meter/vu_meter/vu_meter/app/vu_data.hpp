//
//  vu_data.hpp
//

#pragma once

#include <stdint.h>
#include "yas_base.h"
#include "yas_flow.h"
#include "yas_observing.h"

namespace yas::vu {
struct data : base {
    struct impl;

    enum class method { reference_changed };

    using subject_t = subject<method, data>;
    using observer_t = subject_t::observer_t;

    data();
    data(std::nullptr_t);

    void set_reference(int32_t const);
    int32_t reference() const;
    void set_indicator_count(uint32_t const);
    uint32_t indicator_count() const;

    flow::node_t<int32_t, true> begin_reference_flow() const;
    flow::node_t<bool, true> begin_is_reference_max_flow() const;
    flow::node_t<bool, true> begin_is_reference_min_flow() const;
    flow::receiver<> &reference_increment_receiver();
    flow::receiver<> &reference_decrement_receiver();

    flow::node_t<uint32_t, true> begin_indicator_count_flow() const;
    flow::node_t<bool, true> begin_is_indicator_count_max_flow() const;
    flow::node_t<bool, true> begin_is_indicator_count_min_flow() const;
    flow::receiver<> &indicator_count_increment_receiver();
    flow::receiver<> &indicator_count_decrement_receiver();
};
}  // namespace yas::vu
