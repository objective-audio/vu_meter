//
//  vu_sum_module.cpp
//

#include "vu_sum_module.hpp"
#include "yas_fast_each.h"

using namespace yas;
using namespace yas::proc;

module vu::sum::make_signal_module() {
    auto receive_processor =
        make_receive_signal_processor<float>([](proc::time::range const &, sync_source const &, channel_index_t const,
                                                connector_index_t const, float const *const) {
#warning todo 300ms+新規分を元データで保持する
#warning todo time_rangeが繋がらなかったら保持したいたデータをリセットする
        });

    auto send_processor = make_send_signal_processor<float>(
        [](time::range const &time_range, sync_source const &sync_src, channel_index_t const,
           connector_index_t const co_idx, float *const signal_ptr) {
#warning todo sumしたデータを書き出す
        });

    return module{{std::move(send_processor)}};
}

#pragma mark -

void yas::connect(module &module, vu::sum::output const &output, channel_index_t const &ch_idx) {
    module.connect_output(to_connector_index(output), ch_idx);
}

std::string yas::to_string(vu::sum::output const &output) {
    using namespace yas::vu::sum;

    switch (output) {
        case output::value:
            return "value";
    }

    throw "output not found.";
}
