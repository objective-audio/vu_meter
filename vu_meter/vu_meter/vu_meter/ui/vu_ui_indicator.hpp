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
    class impl;

    void set_vu_height(float const);

    chaining::value::holder_ptr<ui::font_atlas_ptr> const &font_atlas();

    static ui_indicator_resource_ptr make_shared(ui::renderer_ptr const &);

   private:
    std::unique_ptr<impl> _impl;

    ui_indicator_resource(ui::renderer_ptr const &);
};

struct ui_indicator {
    class impl;

    void setup(main_ptr_t const &, ui_indicator_resource_ptr const &, std::size_t const idx);

    ui::node_ptr const &node();

    ui::layout_guide_rect_ptr const &frame_layout_guide_rect();

    static ui_indicator_ptr make_shared();

   private:
    std::weak_ptr<ui_indicator> _weak_indicator;
    std::unique_ptr<impl> _impl;

    ui_indicator();
};
}  // namespace yas::vu
