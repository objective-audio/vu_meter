//
//  vu_ui_indicator_dependency.h
//

#pragma once

#include <ui/yas_ui_umbrella.h>

namespace yas::vu {
struct ui_indicator_resource_interface {
    virtual ~ui_indicator_resource_interface() = default;

    virtual std::shared_ptr<ui::font_atlas> const &font_atlas() const = 0;
    virtual observing::syncable observe_font_atlas(std::function<void(std::shared_ptr<ui::font_atlas> const &)> &&) = 0;
};
}  // namespace yas::vu
