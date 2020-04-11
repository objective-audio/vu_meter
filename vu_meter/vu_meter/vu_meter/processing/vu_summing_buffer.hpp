//
//  vu_summing_buffer.hpp
//

#pragma once

#include <cpp_utils/yas_types.h>
#include <processing/yas_processing_umbrella.h>

#include <optional>
#include <vector>

namespace yas::vu {
struct summing_buffer {
    std::vector<float> pushed;
    std::vector<float> stored;
    std::size_t pos = 0;

    void setup(proc::time::range const &time_range, std::size_t const length);

    void push(float const *const in_ptr, uint32_t const length);

    void fetch_sum(float *const out_ptr, uint32_t const length);

    static void divide(float *const out_ptr, uint32_t const length, float const div);

    void finalize();

   private:
    std::optional<proc::time::range> _last_time_range;
    std::size_t _last_length = 0;
};
}  // namespace yas::vu
