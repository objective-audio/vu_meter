//
//  ui_indicator_resource.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>

#include <observing/umbrella.hpp>

namespace yas::vu {
struct ui_indicator_resource final {
    void set_vu_height(float const);

    [[nodiscard]] std::shared_ptr<ui::font_atlas> const &font_atlas() const;
    [[nodiscard]] observing::syncable observe_font_atlas(
        std::function<void(std::shared_ptr<ui::font_atlas> const &)> &&);

    [[nodiscard]] static std::shared_ptr<ui_indicator_resource> make_shared();

   private:
    class impl;

    std::unique_ptr<impl> _impl;

    ui_indicator_resource(std::shared_ptr<ui::view_look> const &);
};
}  // namespace yas::vu
