//
//  vu_input_module.hpp
//

#pragma once

#include <processing/yas_processing_umbrella.h>

namespace yas::vu::send {
enum class output : proc::connector_index_t {
    value,
};

using handler = std::function<void(proc::time::range const &, proc::connector_index_t const &, float *const)>;

proc::module_ptr make_signal_module(handler);
}  // namespace yas::vu::send

namespace yas {
void connect(proc::module_ptr const &, vu::send::output const &, proc::channel_index_t const &);

std::string to_string(vu::send::output const &);
}  // namespace yas
