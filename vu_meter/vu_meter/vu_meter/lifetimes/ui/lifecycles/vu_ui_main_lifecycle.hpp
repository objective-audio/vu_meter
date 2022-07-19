//
//  vu_ui_main_lifecycle.hpp
//

#pragma once

#include <memory>

namespace yas::vu {
class ui_main_lifetime;

struct ui_main_lifecycle final {
    [[nodiscard]] static std::shared_ptr<ui_main_lifecycle> make_shared();

    std::shared_ptr<ui_main_lifetime> const &lifetime() const;

    void add_lifetime();

   private:
    std::shared_ptr<ui_main_lifetime> _lifetime;
};
}  // namespace yas::vu
