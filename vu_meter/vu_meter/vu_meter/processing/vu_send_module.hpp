//
//  vu_input_module.hpp
//

#pragma once

#include "yas_processing.h"

namespace yas::vu::send {
enum class output : proc::connector_index_t {
    value,
};

using handler = std::function<void(proc::time::range const &, proc::connector_index_t const &, float *const)>;

proc::module make_signal_module(handler);
}

namespace yas {
void connect(proc::module &, vu::send::output const &, proc::channel_index_t const &);

std::string to_string(vu::send::output const &);
}
