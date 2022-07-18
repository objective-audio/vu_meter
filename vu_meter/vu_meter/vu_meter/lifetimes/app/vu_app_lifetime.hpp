//
//  vu_app_lifetime.hpp
//

#pragma once

#include <memory>

namespace yas::vu {
class settings;
class audio_device;
class indicator_lifecycle;
class ui_lifecycle;
class indicator_values;
class main;

struct app_lifetime final {
    [[nodiscard]] static std::shared_ptr<app_lifetime> make_shared();
    app_lifetime();

    std::shared_ptr<settings> const settings;
    std::shared_ptr<audio_device> const audio_device;

    std::shared_ptr<indicator_lifecycle> const indicator_lifecycle;
    std::shared_ptr<ui_lifecycle> const ui_lifecycle;

    std::shared_ptr<indicator_values> const indicator_values;
    std::shared_ptr<main> const main;
};
}  // namespace yas::vu
