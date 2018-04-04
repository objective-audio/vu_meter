//
//  vu_indicator.hpp
//

#pragma once

#include "yas_ui.h"
#include "vu_types.h"
#include "vu_data.hpp"

namespace yas::vu {
struct ui_indicator {
    std::size_t idx;
    ui::node node;
    ui::rect_plane needle = ui::make_rect_plane(1);
    std::vector<ui::node> gridlineHandles;
    std::vector<ui::rect_plane> gridlines;
    ui::font_atlas font_atlas{{.font_name = "AmericanTypewriter-Bold", .font_size = 20.0f, .words = "012357-"}};
    std::vector<ui::strings> numbers;
#warning todo 枠

    void setup(main_ptr_t &main, ui::texture &texture, std::size_t const idx);
    void layout(float const height);

    void update();

   private:
    vu::data::observer_t _data_observer = nullptr;
    weak_main_ptr_t _weak_main;
};
}
