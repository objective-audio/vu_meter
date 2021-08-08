//
//  vu_ui_indicator_container.mm
//

#include "vu_ui_indicator_container.hpp"
#include "vu_app.h"
#include "vu_main.hpp"
#include "vu_ui_indicator_resource.hpp"
#include "vu_ui_utils.hpp"

using namespace yas;
using namespace yas::vu;

ui_indicator_container::ui_indicator_container(std::shared_ptr<vu_ui_indicator_container_presenter> const &presenter,
                                               std::shared_ptr<ui::node> const &root_node,
                                               std::shared_ptr<ui_indicator_factory> const &factory,
                                               std::shared_ptr<ui_indicator_resource> const &resource)
    : _presenter(presenter),
      _root_node(root_node),
      _factory(factory),
      _resource(resource),
      _frame_guide(ui::layout_region_guide::make_shared()) {
    presenter
        ->observe_indicator_count([this](std::size_t const &value) {
            this->_resize_indicators(value);
            this->_update_indicator_regions();
        })
        .sync()
        ->add_to(this->_pool);

    this->_frame_guide->observe([this](ui::region const &) { this->_update_indicator_regions(); })
        .sync()
        ->add_to(this->_pool);
}

void ui_indicator_container::set_frame(ui::region const frame) {
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
        this->_indicators.at(idx)->frame_layout_guide_rect()->set_region(regions.at(idx));
    }
}

void ui_indicator_container::_resize_indicators(std::size_t const value) {
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

void ui_indicator_container::_add_indicator() {
    std::size_t const idx = this->_indicators.size();
    auto indicator = this->_factory->make_indicator(idx);
    this->_root_node->add_sub_node(indicator->node());
    this->_indicators.emplace_back(std::move(indicator));
}

void ui_indicator_container::_remove_last_indicator() {
    if (this->_indicators.size() == 0) {
        throw std::runtime_error("");
    }
    ui_indicator_ptr const &indicator = this->_indicators.at(this->_indicators.size() - 1);
    indicator->node()->remove_from_super_node();
    this->_indicators.pop_back();
}

std::shared_ptr<ui_indicator_container> ui_indicator_container::make_shared() {
    auto const &app = vu::app::shared();
    auto const &root_node = app->ui_standard->root_node();
    auto const &view_look = app->ui_standard->view_look();

    auto const resource = ui_indicator_resource::make_shared(view_look);
    auto const factory = ui_indicator_factory::make_shared(resource);
    auto const presenter = vu_ui_indicator_container_presenter::make_shared(app->main);

    return std::shared_ptr<ui_indicator_container>(new ui_indicator_container{presenter, root_node, factory, resource});
}
