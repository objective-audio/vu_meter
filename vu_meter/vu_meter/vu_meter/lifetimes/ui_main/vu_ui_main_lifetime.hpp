//
//  vu_ui_main_lifetime.hpp
//

#pragma once

#include <memory>

namespace yas::vu {
struct ui_main_lifetime final {
    [[nodiscard]] static std::shared_ptr<ui_main_lifetime> make_shared();
};
}  // namespace yas::vu
