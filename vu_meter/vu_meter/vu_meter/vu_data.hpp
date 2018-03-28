//
//  vu_data.hpp
//

#pragma once

#include <stdint.h>

namespace yas::vu {
struct data {
    data();
    
    void set_reference(int32_t const);
    int32_t reference() const;
};
}
