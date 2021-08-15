//
//  vu_ui_main_dependency.h
//

#pragma once

namespace yas::vu {
struct ui_indicator_container_for_ui_main {
    virtual ~ui_indicator_container_for_ui_main() = default;

    virtual void set_frame(ui::region const) = 0;
};
}  // namespace yas::vu
