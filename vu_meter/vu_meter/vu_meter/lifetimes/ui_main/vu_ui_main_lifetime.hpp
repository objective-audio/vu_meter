//
//  vu_ui_main_lifetime.hpp
//

#pragma once

#include <memory>

namespace yas::vu {
class ui_background;
class ui_indicator_container;

struct ui_main_lifetime final {
    [[nodiscard]] static std::shared_ptr<ui_main_lifetime> make_shared();
    ui_main_lifetime();

    std::shared_ptr<ui_background> const background;
    std::shared_ptr<ui_indicator_container> const indicator_container;
};
}  // namespace yas::vu
