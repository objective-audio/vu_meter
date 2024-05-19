//
//  vu_ui_lifetime.hpp
//

#pragma once

#include <memory>

namespace yas::ui {
class standard;
}

namespace yas::vu {
class ui_main_lifecycle;

struct ui_lifetime final {
    [[nodiscard]] static std::shared_ptr<ui_lifetime> make_shared(std::shared_ptr<ui::standard> const &);
    ui_lifetime(std::shared_ptr<ui::standard> const &);

    std::shared_ptr<ui::standard> const standard;
    std::shared_ptr<ui_main_lifecycle> const main_lifecycle;
};
}  // namespace yas::vu
