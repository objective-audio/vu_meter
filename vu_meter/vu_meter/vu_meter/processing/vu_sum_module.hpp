//
//  vu_sum_module.hpp
//

#pragma once

#include "yas_processing.h"

namespace yas::vu::sum {
enum class output : proc::connector_index_t {
    value,
};

enum class input : proc::connector_index_t {
    value,
};

proc::module make_signal_module(double const duration);
}  // namespace yas::vu::sum

namespace yas {
void connect(proc::module &, vu::sum::output const &, proc::channel_index_t const &);
void connect(proc::module &, vu::sum::input const &, proc::channel_index_t const &);
}  // namespace yas
