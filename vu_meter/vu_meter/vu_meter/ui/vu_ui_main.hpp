//
//  vu_ui.hpp
//

#pragma once

#include <array>
#include "vu_types.h"
#include "vu_ui_indicator.hpp"
#include "vu_ui_reference.hpp"
#include "yas_ui.h"

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
}  // namespace yas::vu
