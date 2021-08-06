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

    bool needs_setup() const;
    void setup(std::shared_ptr<ui::standard> const &standard, main_ptr_t const &main);

    static ui_main_ptr_t make_shared();

   private:
    std::shared_ptr<ui::standard> _standard;

    ui_indicator_resource_ptr _indicator_resource{nullptr};

    weak_main_ptr_t _weak_main;
    std::shared_ptr<ui::layout_region_guide> _frame_guide = ui::layout_region_guide::make_shared();
    std::vector<std::shared_ptr<ui::layout_value_guide>> _guides;
    observing::canceller_pool _pool;

    ui_main() = default;

    void _setup_frame_guide_rect();
    void _setup_indicators(main_ptr_t const &);

    void _add_indicator();
    void _remove_indicator();
};
}  // namespace yas::vu
