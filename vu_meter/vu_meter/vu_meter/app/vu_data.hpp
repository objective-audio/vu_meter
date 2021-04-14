//
//  vu_data.hpp
//

#pragma once

#include <observing/yas_observing_umbrella.h>
#include <stdint.h>

namespace yas::vu {
class data;
using data_ptr = std::shared_ptr<data>;

struct data {
    struct impl;

    int32_t reference() const;

    static data_ptr make_shared();

   private:
    std::unique_ptr<impl> _impl;

    data();
};
}  // namespace yas::vu
