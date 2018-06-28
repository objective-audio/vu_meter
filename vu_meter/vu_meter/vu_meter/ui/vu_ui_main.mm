//
//  vu_ui.mm
//

#include "vu_ui_main.hpp"
#include "vu_main.hpp"
#include "vu_ui_indicator_layout.hpp"
#include "yas_fast_each.h"
#include "yas_flow_utils.h"

using namespace yas;

namespace yas::vu {
static float constexpr padding = 4.0f;
}

void vu::ui_main::setup(ui::renderer &&renderer, main_ptr_t &main) {
    this->_weak_main = main;
    this->renderer = std::move(renderer);
    this->_indicator_resource = ui_indicator_resource(this->renderer);

    ui::texture texture{{.point_size = {1024, 1024}}};
    texture.sync_scale_from_renderer(this->renderer);

    ui_stepper_resource resource{texture};

    this->_setup_frame_guide_rect();
    this->_setup_reference(main, resource);
    this->_setup_indicator_count(main, resource);
    this->_setup_vu_bottom_y_guide();
    this->_setup_indicators(main);
}

void vu::ui_main::_setup_frame_guide_rect() {
    auto const &safe_area_guide_rect = this->renderer.safe_area_layout_guide_rect();

    ui::insets insets{.left = vu::padding, .right = -vu::padding, .bottom = vu::padding, .top = -vu::padding};

    this->_flows.emplace_back(safe_area_guide_rect.begin_flow()
                                  .map(flow::add<ui::region>(insets))
                                  .receive(this->_frame_guide_rect.receiver())
                                  .sync());
}

void vu::ui_main::_setup_reference(main_ptr_t &main, ui_stepper_resource &resource) {
    ui::node &root_node = this->renderer.root_node();

    root_node.add_sub_node(this->reference.node());

    this->reference.setup(main, resource);

    this->_flows.emplace_back(this->_frame_guide_rect.begin_flow()
                                  .map([](ui::region const &region) {
                                      float const height = 60.0f;
                                      bool const is_landscape = region.size.width >= region.size.height;
                                      if (is_landscape) {
                                          float const width = 300.0f;
                                          return ui::region{
                                              .origin = {.x = region.right() - width, .y = region.origin.y},
                                              .size = {.width = width, .height = height}};
                                      } else {
                                          return ui::region{.origin = {.x = region.origin.x, .y = region.origin.y},
                                                            .size = {.width = region.size.width, .height = height}};
                                      }
                                  })
                                  .receive(this->reference.layout_guide_rect().receiver())
                                  .sync());
}

void vu::ui_main::_setup_indicator_count(main_ptr_t &main, ui_stepper_resource &resource) {
    ui::node &root_node = this->renderer.root_node();

    root_node.add_sub_node(this->indicator_count.node());

    this->indicator_count.setup(main, resource);

    this->_flows.emplace_back(
        this->_frame_guide_rect.begin_flow()
            .combine(this->reference.layout_guide_rect().top().begin_flow().map(flow::add(vu::padding)))
            .map([](std::pair<ui::region, float> const &pair) {
                ui::region const &region = pair.first;
                float const height = 60.0f;
                bool const is_landscape = region.size.width >= region.size.height;
                if (is_landscape) {
                    float const width = 300.0f;
                    return ui::region{.origin = {.x = region.origin.x, .y = region.origin.y},
                                      .size = {.width = width, .height = height}};
                } else {
                    float const bottom_y = pair.second;
                    return ui::region{.origin = {.x = region.origin.x, .y = bottom_y},
                                      .size = {.width = region.size.width, .height = height}};
                }
            })
            .receive(this->indicator_count.layout_guide_rect().receiver())
            .sync());
}

void vu::ui_main::_setup_vu_bottom_y_guide() {
    this->_flows.emplace_back(this->indicator_count.layout_guide_rect()
                                  .top()
                                  .begin_flow()
                                  .map(flow::add(vu::padding))
                                  .receive(this->_vu_bottom_y_guide.receiver())
                                  .sync());
}

void vu::ui_main::_setup_indicators(main_ptr_t &main) {
    this->_flows.emplace_back(
        main->data.begin_indicator_count_flow()
            .perform([this](std::size_t const &value) {
                if (value < this->indicators.size()) {
                    auto each = make_fast_each(this->indicators.size() - value);
                    while (yas_each_next(each)) {
                        this->_remove_indicator();
                    }
                } else if (this->indicators.size() < value) {
                    auto each = make_fast_each(value - this->indicators.size());
                    while (yas_each_next(each)) {
                        this->_add_indicator();
                    }
                }
            })
            .to_tuple()
            .combine(this->_frame_guide_rect.begin_flow().to_tuple())
            .combine(this->_vu_bottom_y_guide.begin_flow().to_tuple())
            .map([](std::tuple<std::size_t, ui::region, float> const &tuple) {
                std::size_t const &count = std::get<0>(tuple);
                ui::region const &region = std::get<1>(tuple);
                float const &bottom_y = std::get<2>(tuple);

                return ui_indicator_layout::regions(
                    count, ui::region{.origin = {.x = region.left(), .y = bottom_y},
                                      .size = {.width = region.size.width, .height = region.top() - bottom_y}});
            })
            .perform([this](std::vector<ui::region> const &regions) {
                std::size_t const count = std::min(this->indicators.size(), regions.size());
                auto each = make_fast_each(count);
                while (yas_each_next(each)) {
                    std::size_t const &idx = yas_each_index(each);
                    ui::region const &region = regions.at(idx);
                    this->indicators.at(idx).frame_layout_guide_rect().set_region(region);

                    if (idx == 0) {
                        this->_indicator_resource.set_vu_height(region.size.height);
                    }
                }
            })
            .sync());
}

void vu::ui_main::_add_indicator() {
    if (auto main = this->_weak_main.lock()) {
        std::size_t const idx = this->indicators.size();
        ui_indicator indicator;
        this->renderer.root_node().add_sub_node(indicator.node());
        indicator.setup(main, this->_indicator_resource, idx);
        this->indicators.emplace_back(std::move(indicator));
    }
}

void vu::ui_main::_remove_indicator() {
    if (this->indicators.size() == 0) {
        throw std::runtime_error("");
    }
    ui_indicator &indicator = this->indicators.at(this->indicators.size() - 1);
    indicator.node().remove_from_super_node();
    this->indicators.pop_back();
}
