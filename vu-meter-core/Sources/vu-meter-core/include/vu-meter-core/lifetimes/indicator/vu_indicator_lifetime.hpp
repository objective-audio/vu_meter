//
//  vu_indicator_lifetime.hpp
//

#pragma once

#include <memory>

namespace yas::vu {
class app_lifetime;
class indicator;
class indicator_value;

struct indicator_lifetime final {
    [[nodiscard]] static std::shared_ptr<indicator_lifetime> make_shared(std::shared_ptr<indicator_value> const &);
    indicator_lifetime(std::shared_ptr<indicator_value> const &, std::shared_ptr<app_lifetime> const &);

    std::shared_ptr<indicator> const indicator;
};
}  // namespace yas::vu
