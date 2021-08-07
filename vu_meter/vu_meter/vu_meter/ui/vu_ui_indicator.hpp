//
//  vu_indicator.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>

#include "vu_data.hpp"
#include "vu_types.h"

namespace yas::vu {
class ui_indicator_resource;
class ui_indicator;
using ui_indicator_resource_ptr = std::shared_ptr<ui_indicator_resource>;
using ui_indicator_ptr = std::shared_ptr<ui_indicator>;

struct ui_indicator_resource {
    void set_vu_height(float const);

    observing::value::holder_ptr<std::shared_ptr<ui::font_atlas>> const &font_atlas();

    static ui_indicator_resource_ptr make_shared(std::shared_ptr<ui::view_look> const &);

   private:
    class impl;

    std::unique_ptr<impl> _impl;

    ui_indicator_resource(std::shared_ptr<ui::view_look> const &);
};

struct ui_indicator {
    std::shared_ptr<ui::node> const &node();

    std::shared_ptr<ui::layout_region_guide> const &frame_layout_guide_rect();

    static ui_indicator_ptr make_shared(std::shared_ptr<ui::standard> const &, main_ptr_t const &,
                                        ui_indicator_resource_ptr const &, std::size_t const idx);

   private:
    class impl;

    std::unique_ptr<impl> _impl;

    ui_indicator(std::shared_ptr<ui::standard> const &, main_ptr_t const &, ui_indicator_resource_ptr const &,
                 std::size_t const idx);
};
}  // namespace yas::vu
