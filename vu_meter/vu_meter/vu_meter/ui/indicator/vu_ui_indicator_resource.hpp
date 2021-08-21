//
//  vu_ui_indicator_resource.hpp
//

#pragma once

#include <observing/yas_observing_umbrella.h>
#include <ui/yas_ui_umbrella.h>

#include "vu_ui_indicator_container_dependency.h"
#include "vu_ui_indicator_dependency.h"

namespace yas::vu {
struct ui_indicator_resource final : ui_indicator_resource_for_container, ui_indicator_resource_for_indicator {
    void set_vu_height(float const) override;

    [[nodiscard]] std::shared_ptr<ui::font_atlas> const &font_atlas() const override;
    [[nodiscard]] observing::syncable observe_font_atlas(
        std::function<void(std::shared_ptr<ui::font_atlas> const &)> &&) override;

    [[nodiscard]] static std::shared_ptr<ui_indicator_resource> make_shared();

   private:
    class impl;

    std::unique_ptr<impl> _impl;

    ui_indicator_resource(std::shared_ptr<ui::view_look> const &);
};
}  // namespace yas::vu
