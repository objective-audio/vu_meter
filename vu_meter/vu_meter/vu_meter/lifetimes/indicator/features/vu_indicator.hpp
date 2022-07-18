//
//  vu_indicator.hpp
//

#pragma once

#include <atomic>
#include <memory>

#include "vu_indicator_dependency.h"

namespace yas::vu {
class settings;
class indicator_value;

struct indicator final {
    [[nodiscard]] static std::shared_ptr<indicator> make_shared(std::shared_ptr<indicator_value> const &,
                                                                std::shared_ptr<settings_for_indicator> const &);

    std::shared_ptr<indicator_value> const &raw_value() const;

    [[nodiscard]] float value() const;

   private:
    std::weak_ptr<settings_for_indicator> _weak_settings;
    std::shared_ptr<indicator_value> const _raw_value;

    indicator(std::shared_ptr<indicator_value> const &, std::shared_ptr<settings_for_indicator> const &);
};
}  // namespace yas::vu
