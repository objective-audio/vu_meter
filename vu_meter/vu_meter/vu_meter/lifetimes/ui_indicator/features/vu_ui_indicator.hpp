//
//  vu_indicator.hpp
//

#pragma once

#include <observing/yas_observing_umbrella.hpp>

namespace yas::ui {
class standard;
}

namespace yas::vu {
class ui_indicator_layout;
class ui_indicator_resource;
class ui_indicator_presenter;

struct ui_indicator final {
    [[nodiscard]] static std::shared_ptr<ui_indicator> make_shared(std::size_t const);

    void clean_up();

   private:
    class impl;

    std::unique_ptr<impl> _impl;
    observing::canceller_pool _pool;

    ui_indicator(std::size_t const, ui::standard *, ui_indicator_resource *,
                 std::shared_ptr<ui_indicator_presenter> const &, ui_indicator_layout *);
};
}  // namespace yas::vu
