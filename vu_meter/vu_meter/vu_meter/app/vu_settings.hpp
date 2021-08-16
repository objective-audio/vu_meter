//
//  vu_settings.hpp
//

#pragma once

#include <observing/yas_observing_umbrella.h>

#include "vu_indicator_dependency.h"

namespace yas::vu {
struct settings final : settings_for_indicator {
    int32_t reference() const override;

    static std::shared_ptr<settings> make_shared();

   private:
    struct impl;

    std::unique_ptr<impl> _impl;

    settings();
};
}  // namespace yas::vu
