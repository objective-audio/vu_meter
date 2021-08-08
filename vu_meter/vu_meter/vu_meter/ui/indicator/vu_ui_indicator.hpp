//
//  vu_indicator.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>

#include "vu_ui_indicator_presenter.hpp"
#include "vu_ui_indicator_resource.hpp"

namespace yas::vu {
class ui_indicator;
using ui_indicator_ptr = std::shared_ptr<ui_indicator>;

struct ui_indicator {
    std::shared_ptr<ui::node> const &node();

    std::shared_ptr<ui::layout_region_guide> const &frame_layout_guide_rect();

    static ui_indicator_ptr make_shared(std::shared_ptr<ui::standard> const &,
                                        std::shared_ptr<ui_indicator_resource> const &,
                                        std::shared_ptr<ui_indicator_presenter> const &);

   private:
    class impl;

    std::unique_ptr<impl> _impl;

    ui_indicator(std::shared_ptr<ui::standard> const &, std::shared_ptr<ui_indicator_resource> const &,
                 std::shared_ptr<ui_indicator_presenter> const &);
};
}  // namespace yas::vu
