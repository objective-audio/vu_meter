//
//  vu_data.hpp
//

#pragma once

#include <stdint.h>
#include "yas_observing.h"

namespace yas::vu {
struct data {
    enum class method {
        reference_changed
    };

    using subject_t = subject<method, data>;

    data();
    
    void set_reference(int32_t const);
    int32_t reference() const;
    
    subject_t subject;
};
}
