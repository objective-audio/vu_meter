//
//  vu_ui.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>

namespace yas::vu {
struct ui_background final {
    [[nodiscard]] static std::shared_ptr<ui_background> make_shared();

   private:
    ui_background(ui::view_look *);
};
}  // namespace yas::vu
