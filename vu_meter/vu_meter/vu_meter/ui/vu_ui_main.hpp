//
//  vu_ui.hpp
//

#pragma once

#include <array>
#include "vu_types.h"
#include "vu_ui_indicator.hpp"
#include "vu_ui_indicator_count.hpp"
#include "vu_ui_reference.hpp"
#include "yas_ui.h"

namespace yas::vu {
class main;

struct ui_main {
    ui::renderer renderer{nullptr};

    ui_reference reference;
    ui_indicator_count indicator_count;
    std::vector<ui_indicator> indicators;

    void setup(ui::renderer &&renderer, main_ptr_t &main);

   private:
    ui::layout_guide_rect _frame_guide_rect;
    ui::layout_guide _vu_bottom_y_guide;
    std::vector<ui::layout_guide> _guides;
    std::vector<flow::observer> _flows;

    void _setup_frame_guide_rect();
    void _setup_reference(main_ptr_t &, ui_stepper_resource &);
    void _setup_indicator_count(main_ptr_t &, ui_stepper_resource &);
    void _setup_vu_bottom_y_guide();
    void _setup_indicators(main_ptr_t &);
    void _setup_indicators2(main_ptr_t &);
};
}  // namespace yas::vu
