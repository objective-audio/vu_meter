//
//  vu_indicator.hpp
//

#pragma once

#include "vu_data.hpp"
#include "vu_types.h"
#include "yas_base.h"
#include "yas_ui.h"

namespace yas::vu {
struct ui_indicator : base {
    class impl;

    ui_indicator();
    ui_indicator(std::nullptr_t);

    void setup(main_ptr_t &main, std::size_t const idx);

    ui::node &node();

    ui::layout_guide_rect &frame_layout_guide_rect();
};
}  // namespace yas::vu
