//
//  vu_ui_indicator_layout.cpp
//

#include "vu_ui_indicator_layout.hpp"
#include <ui/yas_ui_umbrella.h>
#include <vu-meter-core/lifetimes/app/lifecycles/vu_indicator_lifecycle.hpp>
#include <vu-meter-core/lifetimes/app/vu_app_lifetime.hpp>
#include <vu-meter-core/lifetimes/global/vu_lifetime_accessor.hpp>
#include <vu-meter-core/lifetimes/ui/vu_ui_lifetime.hpp>
#include <vu-meter-core/lifetimes/ui_main/features/vu_ui_indicator_resource.hpp>
#include <vu-meter-core/ui/utils/vu_ui_utils.hpp>

using namespace yas;
using namespace yas::vu;

namespace yas::vu {
static float constexpr padding = 4.0f;
}

std::shared_ptr<ui_indicator_layout> ui_indicator_layout::make_shared(ui_indicator_resource *resource) {
    auto const &app_lifetime = lifetime_accessor::app_lifetime();
    auto const &ui_lifetime = lifetime_accessor::ui_lifetime();
    return std::make_shared<ui_indicator_layout>(app_lifetime->indicator_lifecycle.get(),
                                                 ui_lifetime->standard->view_look().get(), resource);
}

ui_indicator_layout::ui_indicator_layout(indicator_lifecycle *indicator_lifecycle, ui::view_look *view_look,
                                         ui_indicator_resource *resource)
    : _indicator_lifecycle(indicator_lifecycle),
      _resource(resource),
      _frame_guide(ui::layout_region_guide::make_shared()),
      _regions(observing::value::holder<std::vector<ui::region>>::make_shared({})) {
    view_look->safe_area_layout_guide()
        ->observe([this](ui::region const &region) {
            ui::region_insets const insets{
                .left = vu::padding, .right = -vu::padding, .bottom = vu::padding, .top = -vu::padding};
            this->_frame_guide->set_region(region + insets);
        })
        .sync()
        ->add_to(this->_pool);

    indicator_lifecycle->observe([this](auto const &) { this->_update_regions(); }).end()->add_to(this->_pool);
    this->_frame_guide->observe([this](auto const &) { this->_update_regions(); }).sync()->add_to(this->_pool);
}

std::vector<ui::region> const &ui_indicator_layout::regions() const {
    return this->_regions->value();
}

observing::syncable ui_indicator_layout::observe_regions(
    std::function<void(std::vector<ui::region> const &)> &&handler) {
    return this->_regions->observe(std::move(handler));
}

void ui_indicator_layout::_update_regions() {
    auto const count = this->_indicator_lifecycle->lifetimes().size();
    auto const frame = this->_frame_guide->region();

    auto regions = ui_utils::indicator_regions(count, frame);

    if (!regions.empty()) {
        auto const &height = regions.at(0).size.height;
        this->_resource->set_vu_height(height);
    }

    this->_regions->set_value(std::move(regions));
}
