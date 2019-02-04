//
//  vu_ui.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>
#include <array>
#include "vu_types.h"
#include "vu_ui_indicator.hpp"
#include "vu_ui_reference.hpp"

namespace yas::vu {
class main;

struct ui_main {
    ui::renderer renderer{nullptr};

    std::vector<ui_indicator> indicators;

    void setup(ui::renderer &&renderer, main_ptr_t &main);

   private:
    ui_indicator_resource _indicator_resource{nullptr};

    weak_main_ptr_t _weak_main;
    ui::layout_guide_rect _frame_guide_rect;
    std::vector<ui::layout_guide> _guides;
    chaining::observer_pool _observers;

    void _setup_frame_guide_rect();
    void _setup_indicators(main_ptr_t &);

    void _add_indicator();
    void _remove_indicator();
};
}  // namespace yas::vu
