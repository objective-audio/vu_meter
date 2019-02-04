//
//  vu_ui_reference.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>
#include "vu_ui_stepper.hpp"

namespace yas::vu {
class main;

struct ui_reference {
    void setup(main_ptr_t &, ui_stepper_resource &);

    ui::node &node();
    ui::layout_guide_rect &layout_guide_rect();

   private:
    ui_stepper _stepper;
    chaining::observer_pool _observers;

    void _setup_chainings(main_ptr_t &);
};
}  // namespace yas::vu
