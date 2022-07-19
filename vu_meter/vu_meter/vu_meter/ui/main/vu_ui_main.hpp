//
//  vu_ui.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>

#include <array>

#include "vu_ui_main_dependency.h"
#include "vu_ui_main_presenter.hpp"

namespace yas::vu {
struct ui_main final {
    [[nodiscard]] static std::shared_ptr<ui_main> make_shared();

   private:
    std::shared_ptr<ui_indicator_container_for_ui_main> const _indicator_container;
    std::shared_ptr<ui_main_presenter> const _presenter;

    ui_main(std::shared_ptr<ui::view_look> const &, std::shared_ptr<ui_indicator_container_for_ui_main> const &,
            std::shared_ptr<ui_main_presenter> const &);
};
}  // namespace yas::vu
