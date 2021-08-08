//
//  vu_ui_indicator_container_dependency.h
//

#pragma once

#include <ui/yas_ui_umbrella.h>

namespace yas::vu {
struct ui_indicator_container_indicator_interface {
    virtual ~ui_indicator_container_indicator_interface() = default;

    virtual std::shared_ptr<ui::node> const &node() = 0;
    virtual void set_region(ui::region const) = 0;
};

struct ui_indicator_container_indicator_resource_interface {
    virtual ~ui_indicator_container_indicator_resource_interface() = default;

    virtual void set_vu_height(float const) = 0;
};

struct ui_indicator_container_factory_interface {
    virtual ~ui_indicator_container_factory_interface() = default;

    virtual std::shared_ptr<ui_indicator_container_indicator_interface> make_indicator(std::size_t const idx) = 0;
};
}  // namespace yas::vu
