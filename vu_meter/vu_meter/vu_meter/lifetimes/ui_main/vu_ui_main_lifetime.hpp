//
//  vu_ui_main_lifetime.hpp
//

#pragma once

#include <memory>

namespace yas::vu {
class ui_main;

struct ui_main_lifetime final {
    [[nodiscard]] static std::shared_ptr<ui_main_lifetime> make_shared();
    ui_main_lifetime();

    std::shared_ptr<ui_main> const main;
};
}  // namespace yas::vu
