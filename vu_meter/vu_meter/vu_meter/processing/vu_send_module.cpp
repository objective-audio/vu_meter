//
//  vu_input_module.cpp
//

#include "vu_send_module.hpp"
#include <cpp_utils/yas_fast_each.h>

using namespace yas;
using namespace yas::proc;

module_ptr vu::send::make_signal_module(handler handler) {
    auto make_processors = [handler = std::move(handler)] {
        auto send_processor = make_send_signal_processor<float>(
            [handler = std::move(handler)](time::range const &time_range, sync_source const &sync_src,
                                           channel_index_t const, connector_index_t const co_idx,
                                           float *const signal_ptr) { handler(time_range, co_idx, signal_ptr); });

        return proc::module::processors_t{{std::move(send_processor)}};
    };

    return module::make_shared(std::move(make_processors));
}

#pragma mark -

void yas::connect(module_ptr const &module, vu::send::output const &output, channel_index_t const &ch_idx) {
    module->connect_output(to_connector_index(output), ch_idx);
}

std::string yas::to_string(vu::send::output const &output) {
    using namespace yas::vu::send;

    switch (output) {
        case output::value:
            return "value";
    }

    throw "output not found.";
}
