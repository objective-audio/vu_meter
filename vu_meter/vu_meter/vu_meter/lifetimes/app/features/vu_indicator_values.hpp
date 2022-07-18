//
//  vu_indicator_values.hpp
//

#pragma once

#include <memory>
#include <vector>

namespace yas::vu {
class indicator_value;
class indicator_lifecycle;

struct indicator_values final {
    [[nodiscard]] static std::shared_ptr<indicator_values> make_shared(indicator_lifecycle *);
    indicator_values(indicator_lifecycle *);

    [[nodiscard]] std::vector<std::shared_ptr<indicator_value>> const &raw() const;

    void resize(std::size_t const);

   private:
    std::vector<std::shared_ptr<indicator_value>> _raw;

    indicator_lifecycle *const _lifecycle;
};
}  // namespace yas::vu
