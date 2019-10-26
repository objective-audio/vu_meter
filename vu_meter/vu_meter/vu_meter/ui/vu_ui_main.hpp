//
//  vu_ui.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>
#include <array>
#include "vu_types.h"
#include "vu_ui_indicator.hpp"

namespace yas::vu {
class main;

struct ui_main {
    ui::renderer_ptr renderer{nullptr};

    std::vector<ui_indicator_ptr> indicators;

    void setup(ui::renderer_ptr const &renderer, main_ptr_t const &main);

   private:
    ui_indicator_resource_ptr _indicator_resource{nullptr};

    weak_main_ptr_t _weak_main;
    ui::layout_guide_rect_ptr _frame_guide_rect = ui::layout_guide_rect::make_shared();
    std::vector<ui::layout_guide> _guides;
    chaining::observer_pool _observers;

    void _setup_frame_guide_rect();
    void _setup_indicators(main_ptr_t const &);

    void _add_indicator();
    void _remove_indicator();
};
}  // namespace yas::vu
