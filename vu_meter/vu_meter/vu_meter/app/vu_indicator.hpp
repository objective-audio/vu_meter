//
//  vu_indicator.hpp
//

#pragma once

#include <atomic>
#include <memory>

namespace yas::vu {
class settings;

struct indicator final {
    void set_raw_value(float const);
    float value() const;

    static std::shared_ptr<indicator> make_shared(std::shared_ptr<settings> const &);

   private:
    std::weak_ptr<settings> _weak_settings;
    std::atomic<float> _raw_value;

    indicator(std::shared_ptr<settings> const &);
};
}  // namespace yas::vu
