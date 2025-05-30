//
//  indicator_dependency.h
//

#pragma once

#include <cstdint>

namespace yas::vu {
struct settings_for_indicator {
    virtual ~settings_for_indicator() = default;

    virtual int32_t reference() const = 0;
};
}  // namespace yas::vu
