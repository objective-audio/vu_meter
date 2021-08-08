//
//  vu_ui.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>

#include <array>

#include "vu_ui_indicator.hpp"
#include "vu_ui_main_factories.hpp"

namespace yas::vu {
struct ui_main {
    static std::shared_ptr<ui_main> make_shared();

   private:
    std::shared_ptr<ui::node> const _root_node;
    std::weak_ptr<main> const _weak_main;
    std::shared_ptr<ui_main_indicator_factory> const _indicator_factory;
    std::shared_ptr<ui_indicator_resource> const _indicator_resource;

    std::vector<ui_indicator_ptr> _indicators;

    std::shared_ptr<ui::layout_region_guide> const _frame_guide = ui::layout_region_guide::make_shared();
    std::vector<std::shared_ptr<ui::layout_value_guide>> _guides;
    observing::canceller_pool _pool;

    ui_main(std::shared_ptr<ui::node> const &, std::shared_ptr<ui::view_look> const &, std::shared_ptr<main> const &,
            std::shared_ptr<ui_main_indicator_factory> const &, std::shared_ptr<ui_indicator_resource> const &);

    void _update_indicator_regions();
    void _resize_indicators(std::size_t const);
    void _add_indicator();
    void _remove_last_indicator();
};
}  // namespace yas::vu
