//
//  vu_ui_lifecycle.hpp
//

#pragma once

#include <memory>

namespace yas::ui {
class standard;
}

namespace yas::vu {
class ui_lifetime;

struct ui_lifecycle final {
    [[nodiscard]] static std::shared_ptr<ui_lifecycle> make_shared();
    ui_lifecycle();

    [[nodiscard]] std::shared_ptr<ui_lifetime> const &lifetime() const;

    void add_lifetime(std::shared_ptr<ui::standard> const &);

   private:
    std::shared_ptr<ui_lifetime> _lifetime;
};
}  // namespace yas::vu
