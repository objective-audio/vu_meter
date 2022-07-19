//
//  vu_ui_indicator_container.mm
//

#include "vu_ui_indicator_container.hpp"
#include "vu_audio_graph.hpp"
#include "vu_lifetime_accessor.hpp"
#include "vu_ui_indicator_resource.hpp"
#include "vu_ui_lifetime.hpp"
#include "vu_ui_utils.hpp"

using namespace yas;
using namespace yas::vu;

namespace yas::vu {
static float constexpr padding = 4.0f;
}

ui_indicator_container::ui_indicator_container(std::shared_ptr<vu_ui_indicator_container_presenter> const &presenter,
                                               std::shared_ptr<ui::view_look> const &view_look,
                                               std::shared_ptr<ui::node> const &root_node,
                                               std::shared_ptr<ui_indicator_factory_for_container> const &factory,
                                               std::shared_ptr<ui_indicator_resource_for_container> const &resource)
    : _presenter(presenter),
      _root_node(root_node),
      _factory(factory),
      _resource(resource),
      _frame_guide(ui::layout_region_guide::make_shared()) {
    presenter
        ->observe_indicator_count([this](std::size_t const &size) {
            this->_reload_indicators(size);
            this->_update_indicator_regions();
        })
        .sync()
        ->add_to(this->_pool);

    this->_frame_guide->observe([this](ui::region const &) { this->_update_indicator_regions(); })
        .sync()
        ->add_to(this->_pool);

    view_look->safe_area_layout_guide()
        ->observe([this](ui::region const &region) {
            ui::region_insets const insets{
                .left = vu::padding, .right = -vu::padding, .bottom = vu::padding, .top = -vu::padding};
            this->_set_frame(region + insets);
        })
        .sync()
        ->add_to(this->_pool);
}

void ui_indicator_container::_set_frame(ui::region const frame) {
    this->_frame_guide->set_region(frame);
}

void ui_indicator_container::_update_indicator_regions() {
    auto const count = this->_presenter->indicator_count();
    auto const frame = this->_frame_guide->region();
    auto const regions = ui_utils::indicator_regions(count, frame);

    std::size_t const actual_count = std::min(this->_indicators.size(), regions.size());
    if (actual_count == 0) {
        return;
    }

    this->_resource->set_vu_height(regions.at(0).size.height);

    auto each = make_fast_each(actual_count);
    while (yas_each_next(each)) {
        std::size_t const &idx = yas_each_index(each);
        this->_indicators.at(idx)->set_region(regions.at(idx));
    }
}

void ui_indicator_container::_reload_indicators(std::size_t const size) {
    for (auto const &indicator : this->_indicators) {
        indicator->node()->remove_from_super_node();
    }

    this->_indicators.clear();

    auto each = make_fast_each(size);
    while (yas_each_next(each)) {
        auto const &idx = yas_each_index(each);
        auto indicator = this->_factory->make_indicator(idx);
        this->_root_node->add_sub_node(indicator->node());
        this->_indicators.emplace_back(std::move(indicator));
    }
}

std::shared_ptr<ui_indicator_container> ui_indicator_container::make_shared(
    std::shared_ptr<ui_indicator_factory_for_container> const &factory,
    std::shared_ptr<ui_indicator_resource_for_container> const &resource) {
    auto const &ui_lifetime = lifetime_accessor::ui_lifetime();
    auto const &view_look = ui_lifetime->standard->view_look();
    auto const &root_node = ui_lifetime->standard->root_node();

    auto const presenter = vu_ui_indicator_container_presenter::make_shared();

    return std::shared_ptr<ui_indicator_container>(
        new ui_indicator_container{presenter, view_look, root_node, factory, resource});
}
