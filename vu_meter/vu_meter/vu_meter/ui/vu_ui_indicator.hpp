//
//  vu_indicator.hpp
//

#pragma once

#include "vu_data.hpp"
#include "vu_types.h"
#include "yas_ui.h"

namespace yas::vu {
struct ui_indicator {
    std::size_t idx;
    ui::node node;
    ui::rect_plane base_plane{1};
    ui::node needle_root_node;
    ui::rect_plane needle{1};
    std::vector<ui::node> gridline_handles;
    std::vector<ui::rect_plane> gridlines;
    ui::font_atlas font_atlas{nullptr};
    std::vector<ui::node> number_handles;
    std::vector<ui::strings> numbers;

    ui::layout_guide_rect frame_layout_guide_rect;

    void setup(main_ptr_t &main, std::size_t const idx);

   private:
    flow::observer _node_flow = nullptr;
    flow::observer _frame_flow = nullptr;
    weak_main_ptr_t _weak_main;

    std::vector<flow::observer> _flows;
    flow::observer _renderer_flow = nullptr;
    flow::receiver<ui::renderer> _renderer_receiver = nullptr;
    flow::receiver<> _update_receiver = nullptr;
    flow::receiver<> _layout_receiver = nullptr;
    ui::layout_guide_point _node_guide_point;
    ui::layout_guide_rect _base_guide_rect;

    void _layout();
    void _update();
};
}  // namespace yas::vu
