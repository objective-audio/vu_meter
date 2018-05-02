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
    ui::renderer renderer{nullptr};

    ui_reference reference;
    std::array<ui_indicator, 2> indicators;

    void setup(ui::renderer &&renderer, main_ptr_t &main);

   private:
    ui::renderer::observer_t _renderer_observer;
    std::vector<flow::observer<float>> _flows;
};
}
