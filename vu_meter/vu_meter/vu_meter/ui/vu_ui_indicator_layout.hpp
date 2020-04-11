//
//  vu_ui_indicator_layout.hpp
//

#pragma once

#include <ui/yas_ui_types.h>

#include <vector>

namespace yas::vu {
struct ui_indicator_layout {
    static std::vector<ui::region> regions(std::size_t const count, ui::region const region);
};
}  // namespace yas::vu
