//
//  vu_ui_main_presenter.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>

namespace yas::vu {
struct ui_main_presenter final {
    [[nodiscard]] ui::color const &background_color() const;

    [[nodiscard]] static std::shared_ptr<ui_main_presenter> make_shared();

   private:
    ui_main_presenter();
};
}  // namespace yas::vu
