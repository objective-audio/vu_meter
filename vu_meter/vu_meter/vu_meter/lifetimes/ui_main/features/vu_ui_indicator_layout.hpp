//
//  vu_ui_indicator_layout.hpp
//

#pragma once

#include <ui/yas_ui_types.h>

#include <memory>
#include <observing/yas_observing_umbrella.hpp>

namespace yas::ui {
class layout_region_guide;
class view_look;
}  // namespace yas::ui

namespace yas::vu {
class indicator_lifecycle;
class ui_indicator_resource;

struct ui_indicator_layout final {
    [[nodiscard]] static std::shared_ptr<ui_indicator_layout> make_shared(ui_indicator_resource *);
    ui_indicator_layout(indicator_lifecycle *, ui::view_look *, ui_indicator_resource *);

    [[nodiscard]] std::vector<ui::region> const &regions() const;

    [[nodiscard]] observing::syncable observe_regions(std::function<void(std::vector<ui::region> const &)> &&);

   private:
    indicator_lifecycle *const _indicator_lifecycle;
    ui_indicator_resource *_resource;
    std::shared_ptr<ui::layout_region_guide> const _frame_guide;
    observing::value::holder_ptr<std::vector<ui::region>> const _regions;

    observing::canceller_pool _pool;

    void _update_regions();
};
}  // namespace yas::vu
