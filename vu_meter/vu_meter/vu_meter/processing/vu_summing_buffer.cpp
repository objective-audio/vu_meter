//
//  vu_summing_buffer.cpp
//

#include "vu_summing_buffer.hpp"

#include <Accelerate/Accelerate.h>
#include <cpp_utils/yas_data.h>

using namespace yas;

void vu::summing_buffer::setup(proc::time::range const &time_range, std::size_t const length) {
    bool is_resize = this->_last_length != length;

    if (!is_resize) {
        is_resize = !this->_last_time_range || time_range.frame != this->_last_time_range->next_frame();
    }

    if (is_resize) {
        this->stored.clear();
        this->stored.resize(length);
    }

    this->_last_time_range = time_range;
    this->_last_length = length;
}

void vu::summing_buffer::push(float const *const in_ptr, uint32_t const length) {
    this->pushed.resize(length);
    memcpy(this->pushed.data(), in_ptr, length * sizeof(float));
}

void vu::summing_buffer::fetch_sum(float *const out_ptr, uint32_t const length) {
    // this->storedの合計値
    float sum = 0;
    vDSP_sve(this->stored.data(), 1, &sum, this->stored.size());

    // 1フレームごとに古い値を引いて、新しい値を足す
    auto const data_size = this->stored.size();
    float const *const data_ptr = this->stored.data();
    float const *const pushed_ptr = this->pushed.data();
    auto each = make_fast_each(length);
    while (yas_each_next(each)) {
        auto const &idx = yas_each_index(each);
        auto const data_pos = (this->pos + idx) % data_size;
        sum = sum - data_ptr[data_pos] + pushed_ptr[idx];
        out_ptr[idx] = sum;
    }
}

void vu::summing_buffer::divide(float *const out_ptr, uint32_t const length, float const div) {
    vDSP_vsdiv(out_ptr, 1, &div, out_ptr, 1, static_cast<vDSP_Length>(length));
}

void vu::summing_buffer::finalize() {
    data_copy<float> data_copy{.src_data = {.ptr = this->pushed.data(), .length = this->pushed.size()},
                               .dst_data = {.ptr = this->stored.data(), .length = this->stored.size()},
                               .dst_begin_idx = this->pos,
                               .length = this->pushed.size()};

    auto const result = data_copy.execute_cyclical();

    if (result) {
        this->pos = result.value();
    }

    this->pushed.clear();
}
