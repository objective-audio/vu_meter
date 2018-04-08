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
    ui::rect_plane base_plane{1};
    ui::node needle_root_node;
    ui::rect_plane needle{1};
    std::vector<ui::node> gridlineHandles;
    std::vector<ui::rect_plane> gridlines;
    ui::font_atlas font_atlas{nullptr};
    std::vector<ui::strings> numbers;
    ui::layout_guide_rect layout_guide_rect;

    void setup(main_ptr_t &main, std::size_t const idx);
    void layout();

    void update();

   private:
    vu::data::observer_t _data_observer = nullptr;
    ui::node::observer_t _node_observer = nullptr;
    weak_main_ptr_t _weak_main;
};
}
