//
//  vu_ui.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>

#include <array>

#include "vu_types.h"
#include "vu_ui_indicator.hpp"

namespace yas::vu {
struct ui_main {
    std::vector<ui_indicator_ptr> indicators;

    static ui_main_ptr_t make_shared(std::shared_ptr<ui::standard> const &, main_ptr_t const &);

   private:
    std::shared_ptr<ui::standard> _standard;
    weak_main_ptr_t const _weak_main;
    ui_indicator_resource_ptr const _indicator_resource;

    std::shared_ptr<ui::layout_region_guide> _frame_guide = ui::layout_region_guide::make_shared();
    std::vector<std::shared_ptr<ui::layout_value_guide>> _guides;
    observing::canceller_pool _pool;

    ui_main(std::shared_ptr<ui::standard> const &, main_ptr_t const &);

    void _setup_frame_guide_rect();
    void _setup_indicators(main_ptr_t const &);

    void _add_indicator();
    void _remove_indicator();
};
}  // namespace yas::vu
