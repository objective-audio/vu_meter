//
//  vu_sum_module.hpp
//

#pragma once

#include "yas_processing.h"

namespace yas::vu::sum {
enum class output : proc::connector_index_t {
    value,
};

proc::module make_signal_module();
}

namespace yas {
void connect(proc::module &, vu::sum::output const &, proc::channel_index_t const &);

std::string to_string(vu::sum::output const &);
}
