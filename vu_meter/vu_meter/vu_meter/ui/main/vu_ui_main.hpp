//
//  vu_ui.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>

#include <array>

#include "vu_ui_indicator_container.hpp"
#include "vu_ui_main_presenter.hpp"

namespace yas::vu {
struct ui_main final {
    static std::shared_ptr<ui_main> make_shared();

   private:
    std::shared_ptr<ui_indicator_container> const _indicator_container;
    std::shared_ptr<ui_main_presenter> const _presenter;

    observing::canceller_pool _pool;

    ui_main(std::shared_ptr<ui::view_look> const &, std::shared_ptr<ui_indicator_container> const &,
            std::shared_ptr<ui_main_presenter> const &);
};
}  // namespace yas::vu
