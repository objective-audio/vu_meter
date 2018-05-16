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
    flow::observer<std::nullptr_t> _will_render_flow = nullptr;
    flow::receiver<std::nullptr_t> _will_render_receiver = nullptr;
    std::vector<flow::observer<float>> _flows;
};
}  // namespace yas::vu
