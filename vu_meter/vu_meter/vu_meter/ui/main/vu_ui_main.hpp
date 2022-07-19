//
//  vu_ui.hpp
//

#pragma once

#include <ui/yas_ui_umbrella.h>

namespace yas::vu {
struct ui_main final {
    [[nodiscard]] static std::shared_ptr<ui_main> make_shared();

   private:
    ui_main(std::shared_ptr<ui::view_look> const &);
};
}  // namespace yas::vu
