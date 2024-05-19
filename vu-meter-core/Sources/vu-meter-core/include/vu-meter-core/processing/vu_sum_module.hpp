//
//  vu_sum_module.hpp
//

#pragma once

#include <audio-processing/umbrella.hpp>

namespace yas::vu::sum {
enum class output : proc::connector_index_t {
    value,
};

enum class input : proc::connector_index_t {
    value,
};

proc::module_ptr make_signal_module(double const duration);
}  // namespace yas::vu::sum

namespace yas {
void connect(proc::module_ptr const &, vu::sum::output const &, proc::channel_index_t const &);
void connect(proc::module_ptr const &, vu::sum::input const &, proc::channel_index_t const &);
}  // namespace yas
