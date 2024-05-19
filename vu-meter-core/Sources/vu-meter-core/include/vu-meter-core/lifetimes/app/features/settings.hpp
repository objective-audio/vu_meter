//
//  settings.hpp
//

#pragma once

#include <vu-meter-core/lifetimes/indicator/features/indicator_dependency.h>

#include <observing/umbrella.hpp>

namespace yas::vu {
struct settings final : settings_for_indicator {
    [[nodiscard]] int32_t reference() const override;

    [[nodiscard]] static std::shared_ptr<settings> make_shared();

   private:
    struct impl;

    std::shared_ptr<impl> _impl;

    settings();
};
}  // namespace yas::vu
