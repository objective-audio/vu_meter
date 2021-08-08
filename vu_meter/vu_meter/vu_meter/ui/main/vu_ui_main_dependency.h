//
//  vu_ui_main_dependency.h
//

#pragma once

namespace yas::vu {
struct ui_main_indicator_container_interface {
    virtual ~ui_main_indicator_container_interface() = default;

    virtual void set_frame(ui::region const) = 0;
};
}  // namespace yas::vu
