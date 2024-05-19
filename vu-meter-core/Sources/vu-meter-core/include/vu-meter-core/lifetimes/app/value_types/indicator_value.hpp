//
//  indicator_value.hpp
//

#pragma once

#include <atomic>
#include <memory>

namespace yas::vu {
struct indicator_value final {
    [[nodiscard]] static std::shared_ptr<indicator_value> make_shared();

    void store(float const);
    [[nodiscard]] float load() const;

   private:
    std::atomic<float> _raw_value;
};
}  // namespace yas::vu
