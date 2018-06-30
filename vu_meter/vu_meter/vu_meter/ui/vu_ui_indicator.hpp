//
//  vu_indicator.hpp
//

#pragma once

#include "vu_data.hpp"
#include "vu_types.h"
#include "yas_base.h"
#include "yas_ui.h"

namespace yas::vu {
struct ui_indicator_resource : base {
    class impl;

    ui_indicator_resource(ui::renderer &);
    ui_indicator_resource(std::nullptr_t);

    void set_vu_height(float const);

    flow::property<ui::font_atlas> &font_atlas();
};

struct ui_indicator : base {
    class impl;

    ui_indicator();
    ui_indicator(std::nullptr_t);

    void setup(main_ptr_t &main, ui_indicator_resource resource, std::size_t const idx);

    ui::node &node();

    ui::layout_guide_rect &frame_layout_guide_rect();
};
}  // namespace yas::vu
