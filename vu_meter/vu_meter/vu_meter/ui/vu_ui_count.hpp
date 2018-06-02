//
//  vu_ui_count.hpp
//

#pragma once

#include "vu_ui_stepper.hpp"
#include "yas_ui.h"

namespace yas::vu {
class main;

struct ui_count {
    void setup(main_ptr_t &main, ui::texture &texture);

    ui::node &node();
    ui::layout_guide_rect &layout_guide_rect();

   private:
    ui_stepper _stepper;
    std::vector<flow::observer> _flows;

    void _setup_flows(main_ptr_t &);
};
}  // namespace yas::vu
