//
//  vu_ui_indicator_container_dependency.h
//

#pragma once

#include <ui/yas_ui_umbrella.h>

namespace yas::vu {
struct ui_indicator_for_container {
    virtual ~ui_indicator_for_container() = default;

    virtual std::shared_ptr<ui::node> const &node() = 0;
    virtual void set_region(ui::region const) = 0;
};

struct ui_indicator_resource_for_container {
    virtual ~ui_indicator_resource_for_container() = default;

    virtual void set_vu_height(float const) = 0;
};

struct ui_indicator_factory_for_container {
    virtual ~ui_indicator_factory_for_container() = default;

    virtual std::shared_ptr<ui_indicator_for_container> make_indicator(std::size_t const idx) = 0;
};
}  // namespace yas::vu
