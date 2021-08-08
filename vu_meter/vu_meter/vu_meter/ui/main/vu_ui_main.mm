//
//  vu_ui.mm
//

#include "vu_ui_main.hpp"
#include <cpp_utils/yas_fast_each.h>
#include "vu_app.h"
#include "vu_main.hpp"
#include "vu_ui_color.hpp"
#include "vu_ui_utils.hpp"

using namespace yas;
using namespace yas::vu;

namespace yas::vu {
static float constexpr padding = 4.0f;
}

ui_main::ui_main(std::shared_ptr<ui::node> const &root_node, std::shared_ptr<ui::view_look> const &view_look,
                 std::shared_ptr<main> const &main, std::shared_ptr<ui_main_indicator_factory> const &indicator_factory,
                 std::shared_ptr<ui_indicator_resource> const &resource)
    : _root_node(root_node), _weak_main(main), _indicator_factory(indicator_factory), _indicator_resource(resource) {
    view_look->background()->set_color(vu::base_color());

    view_look->safe_area_layout_guide()
        ->observe([this](ui::region const &region) {
            ui::region_insets const insets{
                .left = vu::padding, .right = -vu::padding, .bottom = vu::padding, .top = -vu::padding};
            this->_frame_guide->set_region(region + insets);
        })
        .sync()
        ->add_to(this->_pool);

    main->observe_indicator_count([this](std::size_t const &value) {
            this->_resize_indicators(value);
            this->_update_indicator_regions();
        })
        .sync()
        ->add_to(this->_pool);

    this->_frame_guide->observe([this](ui::region const &) { this->_update_indicator_regions(); })
        .sync()
        ->add_to(this->_pool);
}

void ui_main::_update_indicator_regions() {
    auto const main = this->_weak_main.lock();
    if (!main) {
        return;
    }

    auto const count = main->indicator_count();
    auto const frame = this->_frame_guide->region();
    auto const regions = ui_utils::indicator_regions(count, frame);

    std::size_t const actual_count = std::min(this->_indicators.size(), regions.size());
    if (actual_count == 0) {
        return;
    }

    this->_indicator_resource->set_vu_height(regions.at(0).size.height);

    auto each = make_fast_each(actual_count);
    while (yas_each_next(each)) {
        std::size_t const &idx = yas_each_index(each);
        this->_indicators.at(idx)->frame_layout_guide_rect()->set_region(regions.at(idx));
    }
}

void ui_main::_resize_indicators(std::size_t const value) {
    if (value < this->_indicators.size()) {
        auto each = make_fast_each(this->_indicators.size() - value);
        while (yas_each_next(each)) {
            this->_remove_last_indicator();
        }
    } else if (this->_indicators.size() < value) {
        auto each = make_fast_each(value - this->_indicators.size());
        while (yas_each_next(each)) {
            this->_add_indicator();
        }
    }
}

void vu::ui_main::_add_indicator() {
    std::size_t const idx = this->_indicators.size();
    auto indicator = this->_indicator_factory->make_indicator(idx);
    this->_root_node->add_sub_node(indicator->node());
    this->_indicators.emplace_back(std::move(indicator));
}

void vu::ui_main::_remove_last_indicator() {
    if (this->_indicators.size() == 0) {
        throw std::runtime_error("");
    }
    ui_indicator_ptr const &indicator = this->_indicators.at(this->_indicators.size() - 1);
    indicator->node()->remove_from_super_node();
    this->_indicators.pop_back();
}

std::shared_ptr<ui_main> vu::ui_main::make_shared() {
    auto const &app = vu::app::shared();
    auto const &root_node = app->ui_standard->root_node();
    auto const &view_look = app->ui_standard->view_look();
    auto const resource = ui_indicator_resource::make_shared(view_look);
    auto const factory = ui_main_indicator_factory::make_shared(resource);

    return std::shared_ptr<ui_main>(new ui_main{root_node, view_look, app->main, factory, resource});
}
