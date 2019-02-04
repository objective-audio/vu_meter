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

    chaining::value::holder<int32_t> &reference();

    chaining::chain_sync_t<bool> begin_is_reference_max_flow() const;
    chaining::chain_sync_t<bool> begin_is_reference_min_flow() const;
    chaining::receiver<> &reference_increment_receiver();
    chaining::receiver<> &reference_decrement_receiver();
};
}  // namespace yas::vu
