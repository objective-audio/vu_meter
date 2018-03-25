//
//  vu_summing_buffer.hpp
//

#pragma once

#include "yas_processing.h"
#include <vector>
#include <experimental/optional>

namespace yas::vu {
struct summing_buffer {
    std::vector<float> pushed;
    std::vector<float> stored;
    std::size_t pos = 0;

    void setup(proc::time::range const &time_range, std::size_t const length);

    void push(float const *const in_ptr, uint32_t const length);

    void fetch_sum(float *const out_ptr, uint32_t const length);

    void finalize();

   private:
    std::experimental::optional<proc::time::range> _last_time_range;
    proc::sample_rate_t _last_length = 0;
};
}
