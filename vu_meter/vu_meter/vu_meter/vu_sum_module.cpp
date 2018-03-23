//
//  vu_sum_module.cpp
//

#include "vu_sum_module.hpp"
#include "yas_fast_each.h"
#import <Accelerate/Accelerate.h>

using namespace yas;
using namespace yas::proc;

namespace yas::vu {
struct summing_buffer {
    std::vector<float> pushed;
    std::vector<float> stored;
    std::size_t pos = 0;

    void setup(proc::time::range const &time_range, proc::sample_rate_t const sample_rate) {
        bool is_resize = this->_last_sample_rate != sample_rate;

        if (!is_resize) {
            is_resize = !this->_last_time_range || time_range.frame != this->_last_time_range->next_frame();
        }

        if (is_resize) {
            this->stored.clear();
            this->stored.resize(static_cast<std::size_t>(sample_rate * (3.0 / 10.0)));
        }
    }

    void push(float const *const in_ptr, uint32_t const length) {
        this->pushed.clear();
        this->pushed.resize(length);
        memcpy(this->pushed.data(), in_ptr, length * sizeof(float));
    }

    void fetch_sum(float *const out_ptr, uint32_t const length) {
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

    void finalize() {
        std::size_t idx = 0;
        float *const stored_data = this->stored.data();
        float const *const pushed_data = this->pushed.data();
        std::size_t const pushed_length = this->pushed.size();

        while (idx < pushed_length) {
            std::size_t const stored_remain = this->stored.size() - this->pos;
            std::size_t const pushed_remain = pushed_length - idx;
            std::size_t const copy_length = std::min(pushed_remain, stored_remain);
            memcpy(&stored_data[this->pos], &pushed_data[idx], copy_length * sizeof(float));

            idx = idx + copy_length;
            this->pos = (this->pos + copy_length) % this->stored.size();
        }
    }

   private:
    std::experimental::optional<proc::time::range> _last_time_range;
    proc::sample_rate_t _last_sample_rate = 0;
};
}

module vu::sum::make_signal_module() {
    auto buffer = std::make_shared<summing_buffer>();

    auto receive_processor = make_receive_signal_processor<float>(
        [buffer](proc::time::range const &time_range, sync_source const &sync_source, channel_index_t const,
                 connector_index_t const, float const *const signal_ptr) {
            buffer->setup(time_range, sync_source.sample_rate);
            buffer->push(signal_ptr, static_cast<uint32_t>(time_range.length));
        });

    auto send_processor = make_send_signal_processor<float>(
        [buffer](time::range const &time_range, sync_source const &sync_src, channel_index_t const,
                 connector_index_t const co_idx, float *const signal_ptr) {
            buffer->fetch_sum(signal_ptr, static_cast<uint32_t>(time_range.length));
            buffer->finalize();
        });

    return module{{std::move(send_processor)}};
}

#pragma mark -

void yas::connect(module &module, vu::sum::output const &output, channel_index_t const &ch_idx) {
    module.connect_output(to_connector_index(output), ch_idx);
}

void yas::connect(module &module, vu::sum::input const &input, channel_index_t const &ch_idx) {
    module.connect_input(to_connector_index(input), ch_idx);
}
