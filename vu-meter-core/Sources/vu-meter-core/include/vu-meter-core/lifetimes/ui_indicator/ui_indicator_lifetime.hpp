//
//  ui_indicator_lifetime.hpp
//

#pragma once

#include <memory>

namespace yas::vu {
class ui_indicator;

struct ui_indicator_lifetime final {
    [[nodiscard]] static std::shared_ptr<ui_indicator_lifetime> make_shared(std::size_t const);
    ui_indicator_lifetime(std::size_t const);

    std::shared_ptr<ui_indicator> const indicator;
};
}  // namespace yas::vu
