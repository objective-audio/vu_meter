//
//  vu_ui.hpp
//

#pragma once

#include "yas_ui.h"
#include "vu_ui_reference.hpp"
#include "vu_ui_indicator.hpp"
#include "vu_types.h"
#include <array>

namespace yas::vu {
class main;

struct ui_main {
    ui::renderer renderer{ui::metal_system{make_objc_ptr(MTLCreateSystemDefaultDevice()).object()}};

    ui_reference reference;
    std::array<ui_indicator, 2> indicators;

    void setup(main_ptr_t &main);

   private:
    ui::renderer::observer_t _renderer_observer;
};
}
