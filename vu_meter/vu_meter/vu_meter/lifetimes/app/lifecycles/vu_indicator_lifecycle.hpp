//
//  vu_indicator_lifecycle.hpp
//

#pragma once

#include <observing/umbrella.hpp>

namespace yas::vu {
class indicator_value;
class indicator_lifetime;

struct indicator_lifecycle final {
    using indicator_lifetimes = std::vector<std::shared_ptr<indicator_lifetime>>;

    [[nodiscard]] static std::shared_ptr<indicator_lifecycle> make_shared();
    indicator_lifecycle();

    [[nodiscard]] std::vector<std::shared_ptr<indicator_lifetime>> const &lifetimes() const;

    void reload(std::vector<std::shared_ptr<indicator_value>> const &);

    [[nodiscard]] observing::syncable observe(std::function<void(indicator_lifetimes const &)> &&);

   private:
    observing::value::holder_ptr<indicator_lifetimes> const _lifetimes;
};
}  // namespace yas::vu
