//
//  vu_sum_module.cpp
//

#include "vu_sum_module.hpp"
#include "vu_summing_buffer.hpp"

using namespace yas;
using namespace yas::proc;

module vu::sum::make_signal_module(double const duration) {
    auto buffer = std::make_shared<summing_buffer>();

    auto receive_processor = make_receive_signal_processor<float>(
        [buffer, duration](proc::time::range const &time_range, sync_source const &sync_source, channel_index_t const,
                           connector_index_t const, float const *const signal_ptr) {
            buffer->setup(time_range, sync_source.sample_rate * duration);
            buffer->push(signal_ptr, static_cast<uint32_t>(time_range.length));
        });

    auto send_processor = make_send_signal_processor<float>(
        [buffer, duration](time::range const &time_range, sync_source const &sync_source, channel_index_t const,
                           connector_index_t const co_idx, float *const signal_ptr) {
            auto const length = static_cast<uint32_t>(time_range.length);
            buffer->fetch_sum(signal_ptr, length);
            buffer->divide(signal_ptr, length, sync_source.sample_rate * duration);
            buffer->finalize();
        });

    return module{{std::move(receive_processor), std::move(send_processor)}};
}

#pragma mark -

void yas::connect(module &module, vu::sum::output const &output, channel_index_t const &ch_idx) {
    module.connect_output(to_connector_index(output), ch_idx);
}

void yas::connect(module &module, vu::sum::input const &input, channel_index_t const &ch_idx) {
    module.connect_input(to_connector_index(input), ch_idx);
}
