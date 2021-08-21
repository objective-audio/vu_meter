//
//  vu_ui_indicator_dependency.h
//

#pragma once

#include <ui/yas_ui_umbrella.h>

namespace yas::vu {
struct ui_indicator_resource_for_indicator {
    virtual ~ui_indicator_resource_for_indicator() = default;

    [[nodiscard]] virtual std::shared_ptr<ui::font_atlas> const &font_atlas() const = 0;
    [[nodiscard]] virtual observing::syncable observe_font_atlas(
        std::function<void(std::shared_ptr<ui::font_atlas> const &)> &&) = 0;
};
}  // namespace yas::vu
