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
#include "vu_ui_main_dependency.h"

namespace yas::vu {
struct ui_indicator_container final : ui_indicator_container_for_ui_main {
    void set_frame(ui::region const) override;

    [[nodiscard]] static std::shared_ptr<ui_indicator_container> make_shared();

   private:
    std::shared_ptr<vu_ui_indicator_container_presenter> const _presenter;
    std::shared_ptr<ui::node> const _root_node;
    std::vector<std::shared_ptr<ui_indicator_for_container>> _indicators;
    std::shared_ptr<ui_indicator_factory_for_container> const _factory;
    std::shared_ptr<ui_indicator_resource_for_container> const _resource;
    std::shared_ptr<ui::layout_region_guide> const _frame_guide;

    observing::canceller_pool _pool;

    ui_indicator_container(std::shared_ptr<vu_ui_indicator_container_presenter> const &,
                           std::shared_ptr<ui::node> const &,
                           std::shared_ptr<ui_indicator_factory_for_container> const &,
                           std::shared_ptr<ui_indicator_resource_for_container> const &);

    void _update_indicator_regions();
    void _resize_indicators(std::size_t const);
    void _add_indicator();
    void _remove_last_indicator();
};
}  // namespace yas::vu
