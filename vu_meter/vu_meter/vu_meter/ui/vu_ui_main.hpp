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
    std::array<ui_indicator, 2> indicators;

    void setup(ui::renderer &&renderer, main_ptr_t &main);

   private:
    ui::layout_guide_rect _frame_guide_rect;
    std::array<ui::layout_guide, 4> _guides;
    std::vector<flow::observer> _flows;

    void _setup_frame();
    void _setup_reference(main_ptr_t &, ui_stepper_resource &);
    void _setup_indicator_count(main_ptr_t &, ui_stepper_resource &);
    void _setup_indicators(main_ptr_t &, ui::texture &);
};
}  // namespace yas::vu
