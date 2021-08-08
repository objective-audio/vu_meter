//
//  vu_settings.hpp
//

#pragma once

#include <observing/yas_observing_umbrella.h>
#include <stdint.h>

namespace yas::vu {
struct settings {
    int32_t reference() const;

    static std::shared_ptr<settings> make_shared();

   private:
    struct impl;

    std::unique_ptr<impl> _impl;

    settings();
};
}  // namespace yas::vu
