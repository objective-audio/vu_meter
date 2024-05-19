//
//  ui_indicator_lifecycle.hpp
//

#pragma once

#include <memory>
#include <vector>

namespace yas::vu {
class ui_indicator_lifetime;

struct ui_indicator_lifecycle final {
    [[nodiscard]] static std::shared_ptr<ui_indicator_lifecycle> make_shared();

    void reload(std::size_t const);

    std::vector<std::shared_ptr<ui_indicator_lifetime>> const &lifetimes() const;

   private:
    std::vector<std::shared_ptr<ui_indicator_lifetime>> _lifetimes;
};
}  // namespace yas::vu
