//
//  vu_data.hpp
//

#pragma once

#include <chaining/yas_chaining_umbrella.h>
#include <stdint.h>

namespace yas::vu {
class data;
using data_ptr = std::shared_ptr<data>;

struct data {
    struct impl;

    chaining::value::holder_ptr<int32_t> const &reference();

    chaining::chain_sync_t<bool> is_reference_max_chain() const;
    chaining::chain_sync_t<bool> is_reference_min_chain() const;
    chaining::receiver_ptr<std::nullptr_t> reference_increment_receiver();
    chaining::receiver_ptr<std::nullptr_t> reference_decrement_receiver();

    static data_ptr make_shared();

   private:
    std::unique_ptr<impl> _impl;

    data();

    void _prepare(data_ptr const &);
};
}  // namespace yas::vu
