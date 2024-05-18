//
//  vu_settings.hpp
//

#pragma once

#include <observing/umbrella.hpp>

#include "vu_indicator_dependency.h"

namespace yas::vu {
struct settings final : settings_for_indicator {
    [[nodiscard]] int32_t reference() const override;

    [[nodiscard]] static std::shared_ptr<settings> make_shared();

   private:
    struct impl;

    std::unique_ptr<impl> _impl;

    settings();
};
}  // namespace yas::vu
