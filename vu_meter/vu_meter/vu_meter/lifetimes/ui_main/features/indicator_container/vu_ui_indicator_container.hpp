//
//  vu_ui_indicator_container.hpp
//

#pragma once

#include <memory>
#include <vector>

#include "vu_ui_indicator.hpp"
#include "vu_ui_indicator_container_dependency.h"
#include "vu_ui_indicator_container_presenter.hpp"
#include "vu_ui_indicator_factory.hpp"

namespace yas::vu {
struct ui_indicator_container final {
    [[nodiscard]] static std::shared_ptr<ui_indicator_container> make_shared(
        std::shared_ptr<ui_indicator_factory_for_container> const &,
        std::shared_ptr<ui_indicator_resource_for_container> const &);

    void setup();

   private:
    std::shared_ptr<vu_ui_indicator_container_presenter> const _presenter;
    ui::view_look *const _view_look;
    std::shared_ptr<ui::node> const _root_node;
    std::vector<std::shared_ptr<ui_indicator_for_container>> _indicators;
    std::shared_ptr<ui_indicator_factory_for_container> const _factory;
    std::shared_ptr<ui_indicator_resource_for_container> const _resource;
    std::shared_ptr<ui::layout_region_guide> const _frame_guide;

    observing::canceller_pool _pool;

    ui_indicator_container(std::shared_ptr<vu_ui_indicator_container_presenter> const &,
                           std::shared_ptr<ui::view_look> const &, std::shared_ptr<ui::node> const &,
                           std::shared_ptr<ui_indicator_factory_for_container> const &,
                           std::shared_ptr<ui_indicator_resource_for_container> const &);

    void _set_frame(ui::region const);
    void _update_indicator_regions();
    void _reload_indicators(std::size_t const);
};
}  // namespace yas::vu
