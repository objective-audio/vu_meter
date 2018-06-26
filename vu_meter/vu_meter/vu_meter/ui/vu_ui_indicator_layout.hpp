//
//  vu_ui_indicator_layout.hpp
//

#pragma once

#include "yas_ui_types.h"

namespace yas::vu {
struct ui_indicator_layout {
    ui_indicator_layout(std::size_t const count, ui::region const region);

   private:
    std::size_t _count;
    ui::region _region;
};
}  // namespace yas::vu
