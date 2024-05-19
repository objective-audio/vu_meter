//
//  vu_ui_main_lifetime.hpp
//

#pragma once

#include <memory>

namespace yas::vu {
class ui_background;
class ui_indicator_resource;
class ui_indicator_layout;
class ui_indicator_lifecycle;
class ui_indicators;

struct ui_main_lifetime final {
    [[nodiscard]] static std::shared_ptr<ui_main_lifetime> make_shared();
    ui_main_lifetime();

    std::shared_ptr<ui_background> const background;
    std::shared_ptr<ui_indicator_resource> const indicator_resource;
    std::shared_ptr<ui_indicator_layout> const indicator_layout;
    std::shared_ptr<ui_indicator_lifecycle> const indicator_lifecycle;
    std::shared_ptr<ui_indicators> const indicators;
};
}  // namespace yas::vu
