//
//  vu_ui_count.hpp
//

#pragma once

#include "vu_data.hpp"
#include "vu_types.h"
#include "yas_ui.h"

namespace yas::vu {
struct ui_count {
    ui::node node;

    void setup(main_ptr_t &main, ui::texture &texture);
};
}  // namespace yas::vu
