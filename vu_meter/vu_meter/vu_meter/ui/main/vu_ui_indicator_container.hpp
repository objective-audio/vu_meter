//
//  vu_ui_indicator_container.hpp
//

#pragma once

#include <memory>
#include <vector>

#include "vu_ui_indicator.hpp"
#include "vu_ui_main_factories.hpp"

namespace yas::vu {
struct ui_indicator_container final {
    void set_frame(ui::region const);

    static std::shared_ptr<ui_indicator_container> make_shared(std::shared_ptr<main> const &,
                                                               std::shared_ptr<ui::node> const &,
                                                               std::shared_ptr<ui_main_indicator_factory> const &,
                                                               std::shared_ptr<ui_indicator_resource> const &);

   private:
    std::weak_ptr<main> const _weak_main;
    std::shared_ptr<ui::node> const _root_node;
    std::vector<ui_indicator_ptr> _indicators;
    std::shared_ptr<ui_main_indicator_factory> const _factory;
    std::shared_ptr<ui_indicator_resource> const _resource;
    std::shared_ptr<ui::layout_region_guide> const _frame_guide;

    observing::canceller_pool _pool;

    ui_indicator_container(std::shared_ptr<main> const &, std::shared_ptr<ui::node> const &,
                           std::shared_ptr<ui_main_indicator_factory> const &,
                           std::shared_ptr<ui_indicator_resource> const &);

    void _update_indicator_regions();
    void _resize_indicators(std::size_t const);
    void _add_indicator();
    void _remove_last_indicator();
};
}  // namespace yas::vu
