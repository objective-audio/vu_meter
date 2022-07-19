//
//  vu_lifetime_accessor.hpp
//

#pragma once

#include <memory>

namespace yas::vu {
class app_lifecycle;
class app_lifetime;
class ui_lifetime;
class ui_main_lifetime;
class indicator_lifetime;

struct lifetime_accessor final {
    [[nodiscard]] static std::shared_ptr<app_lifecycle> const &app_lifecycle();

    [[nodiscard]] static std::shared_ptr<app_lifetime> const &app_lifetime();
    [[nodiscard]] static std::shared_ptr<ui_lifetime> const &ui_lifetime();
    [[nodiscard]] static std::shared_ptr<indicator_lifetime> const &indicator_lifetime(std::size_t const idx);
    [[nodiscard]] static std::shared_ptr<ui_main_lifetime> const &ui_main_lifetime();
};
}  // namespace yas::vu
