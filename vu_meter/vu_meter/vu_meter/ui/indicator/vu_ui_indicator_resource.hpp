//
//  vu_ui_indicator_resource.hpp
//

#pragma once

#include <observing/yas_observing_umbrella.h>
#include <ui/yas_ui_umbrella.h>

namespace yas::vu {
struct ui_indicator_resource {
    void set_vu_height(float const);

    observing::value::holder_ptr<std::shared_ptr<ui::font_atlas>> const &font_atlas();

    static std::shared_ptr<ui_indicator_resource> make_shared(std::shared_ptr<ui::view_look> const &);

   private:
    class impl;

    std::unique_ptr<impl> _impl;

    ui_indicator_resource(std::shared_ptr<ui::view_look> const &);
};
}  // namespace yas::vu
