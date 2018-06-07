//
//  vu_ui.mm
//

#include "vu_ui_main.hpp"
#include "vu_main.hpp"
#include "yas_fast_each.h"
#include "yas_flow_utils.h"

using namespace yas;

namespace yas::vu {
static float constexpr padding = 4.0f;
}

void vu::ui_main::setup(ui::renderer &&renderer, main_ptr_t &main) {
    this->_weak_main = main;
    this->renderer = std::move(renderer);

    ui::texture texture{{.point_size = {1024, 1024}}};
    texture.sync_scale_from_renderer(this->renderer);

    ui_stepper_resource resource{texture};

    this->_setup_frame_guide_rect();
    this->_setup_reference(main, resource);
    this->_setup_indicator_count(main, resource);
    this->_setup_vu_bottom_y_guide();
    //    this->_setup_indicators(main);
    this->_setup_indicators2(main);
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

    this->_flows.emplace_back(this->_frame_guide_rect.begin_flow()
                                  .map([](ui::region const &region) {
                                      float const height = 60.0f;
                                      bool const is_landscape = region.size.width >= region.size.height;
                                      if (is_landscape) {
                                          float const width = 300.0f;
                                          return ui::region{.origin = {.x = region.origin.x, .y = region.origin.y},
                                                            .size = {.width = width, .height = height}};
                                      } else {
                                          return ui::region{
                                              .origin = {.x = region.origin.x, .y = region.origin.y + height},
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
    std::size_t constexpr count = 2;

    ui::node &root_node = this->renderer.root_node();

    this->_guides.resize(count * 2);

    std::vector<flow::receiver<float>> guide_receivers;
    for (auto &guide : this->_guides) {
        guide_receivers.push_back(guide.receiver());
    }

    this->_flows.emplace_back(this->_frame_guide_rect.left()
                                  .begin_flow()
                                  .combine(this->_frame_guide_rect.right().begin_flow())
                                  .map(ui::justify<3>(std::array<float, 3>{100.0f, 1.0f, 100.0f}))
                                  .receive(guide_receivers)
                                  .sync());

    ui::layout_guide center_y_guide;

    this->_flows.emplace_back(this->_frame_guide_rect.top()
                                  .begin_flow()
                                  .combine(this->_vu_bottom_y_guide.begin_flow())
                                  .map(ui::justify())
                                  .receive(center_y_guide.receiver())
                                  .sync());

    auto each = make_fast_each(count);

    while (yas_each_next(each)) {
        std::size_t const &idx = yas_each_index(each);

        auto &indicator = this->indicators.emplace_back();
        root_node.add_sub_node(indicator.node());
        indicator.setup(main, idx);

        auto make_vertical_flow = [](ui::layout_guide &src_left, ui::layout_guide &src_right, ui::layout_guide &src_y,
                                     ui::layout_guide &dst_bottom, ui::layout_guide &dst_top) {
            return src_left.begin_flow()
                .combine(src_right.begin_flow())
                .combine(src_y.begin_flow())
                .perform([dst_bottom, dst_top](auto const &pair) mutable {
                    float const src_left = pair.first.first;
                    float const src_right = pair.first.second;
                    float const src_y = pair.second;
                    float const height = (src_right - src_left) * 0.5f;

                    dst_bottom.push_notify_waiting();
                    dst_top.push_notify_waiting();

                    dst_bottom.set_value(std::round(src_y - height * 0.5f));
                    dst_top.set_value(std::round(src_y + height * 0.5f));

                    dst_top.pop_notify_waiting();
                    dst_bottom.pop_notify_waiting();
                })
                .sync();
        };

        auto &left_guide = this->_guides.at(idx * 2);
        auto &right_guide = this->_guides.at(idx * 2 + 1);

        this->_flows.emplace_back(
            left_guide.begin_flow().receive(indicator.frame_layout_guide_rect().left().receiver()).sync());
        this->_flows.emplace_back(
            right_guide.begin_flow().receive(indicator.frame_layout_guide_rect().right().receiver()).sync());
        this->_flows.emplace_back(make_vertical_flow(left_guide, right_guide, center_y_guide,
                                                     indicator.frame_layout_guide_rect().bottom(),
                                                     indicator.frame_layout_guide_rect().top()));
    }
}

void vu::ui_main::_setup_indicators2(main_ptr_t &main) {
    this->_flows.emplace_back(
        main->data.begin_indicator_count_flow()
            .perform([this](std::size_t const &value) {
                if (value < this->indicators2.size()) {
                    auto each = make_fast_each(this->indicators2.size() - value);
                    while (yas_each_next(each)) {
                        this->_remove_indicator();
                    }
                } else if (this->indicators2.size() < value) {
                    auto each = make_fast_each(value - this->indicators2.size());
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

                std::vector<ui::region> result;
                result.reserve(count);

                if (count == 0) {
                    return result;
                }

                bool const is_landscape = region.size.width > region.size.height;
                std::size_t const ratio_count = count + count - 1;

                if (true || is_landscape) {
                    float const center_y = bottom_y + (region.top() - bottom_y) * 0.5f;
                    auto justify_handler = ui::justify([](std::size_t const &idx) { return idx % 2 ? 1.0f : 100.0f; });
                    auto positions = justify_handler(std::make_tuple(region.left(), region.right(), ratio_count));
                    auto each = make_fast_each(count);
                    while (yas_each_next(each)) {
                        std::size_t const &idx = yas_each_index(each);
                        std::size_t const left_idx = idx * 2;
                        std::size_t const right_idx = left_idx + 1;
                        float const left = positions.at(left_idx);
                        float const right = positions.at(right_idx);
                        float const width = right - left;
                        float const height = width * 0.5f;
                        float const bottom = center_y - height * 0.5f;
                        result.emplace_back(
                            ui::region{.origin = {.x = left, .y = bottom}, .size = {.width = width, .height = height}});
                    }
                } else {
                    auto justify = ui::justify([](std::size_t const &idx) { return idx % 2 ? 50.0f : 1.0f; });
#warning todo 縦の場合
                }

                return result;
            })
            .perform([this](std::vector<ui::region> const &regions) {
                std::size_t const count = std::min(this->indicators2.size(), regions.size());
                auto each = make_fast_each(count);
                while (yas_each_next(each)) {
                    std::size_t const &idx = yas_each_index(each);
                    this->indicators2.at(idx).frame_layout_guide_rect().set_region(regions.at(idx));
                }
            })
            .sync());
}

void vu::ui_main::_add_indicator() {
    if (auto main = this->_weak_main.lock()) {
        std::size_t const idx = this->indicators2.size();
        ui_indicator indicator;
        this->renderer.root_node().add_sub_node(indicator.node());
        indicator.setup(main, idx);
        this->indicators2.emplace_back(std::move(indicator));
    }
}

void vu::ui_main::_remove_indicator() {
    if (this->indicators2.size() == 0) {
        throw std::runtime_error("");
    }
    ui_indicator &indicator = *this->indicators2.end();
    indicator.node().remove_from_super_node();
    this->indicators2.pop_back();
}
