//
//  vu_ui.mm
//

#include "vu_ui_main.hpp"
#include "vu_main.hpp"
#include "yas_flow_utils.h"

using namespace yas;

void vu::ui_main::setup(ui::renderer &&renderer, main_ptr_t &main) {
    this->renderer = std::move(renderer);

    ui::texture texture{{.point_size = {1024, 1024}}};
    texture.observe_scale_from_renderer(this->renderer);

    this->_setup_reference(main, texture);
    this->_setup_indicator_count(main, texture);
    this->_setup_indicators(main, texture);
}

void vu::ui_main::_setup_reference(main_ptr_t &main, ui::texture &texture) {
    ui::node &root_node = this->renderer.root_node();
    auto const &safe_area_guide_rect = this->renderer.safe_area_layout_guide_rect();

    root_node.add_sub_node(this->reference.node());

    this->reference.setup(main, texture);

    this->_flows.emplace_back(safe_area_guide_rect.bottom()
                                  .begin_flow()
                                  .receive(this->reference.layout_guide_rect().bottom().receiver())
                                  .map(flow::add(60.0f))
                                  .receive(this->reference.layout_guide_rect().top().receiver())
                                  .sync());
    this->_flows.emplace_back(safe_area_guide_rect.right()
                                  .begin_flow()
                                  .map([](float const &value) { return value - 300.0f; })
                                  .receive(this->reference.layout_guide_rect().left().receiver())
                                  .sync());
    this->_flows.emplace_back(safe_area_guide_rect.right()
                                  .begin_flow()
                                  .receive(this->reference.layout_guide_rect().right().receiver())
                                  .sync());
}

void vu::ui_main::_setup_indicator_count(main_ptr_t &main, ui::texture &texture) {
    ui::node &root_node = this->renderer.root_node();
    auto const &safe_area_guide_rect = this->renderer.safe_area_layout_guide_rect();

    root_node.add_sub_node(this->indicator_count.node());

    this->indicator_count.setup(main, texture);

    this->_flows.emplace_back(safe_area_guide_rect.bottom()
                                  .begin_flow()
                                  .receive(this->indicator_count.layout_guide_rect().bottom().receiver())
                                  .map(flow::add(60.0f))
                                  .receive(this->indicator_count.layout_guide_rect().top().receiver())
                                  .sync());
    this->_flows.emplace_back(safe_area_guide_rect.left()
                                  .begin_flow()
                                  .receive(this->indicator_count.layout_guide_rect().left().receiver())
                                  .sync());
    this->_flows.emplace_back(safe_area_guide_rect.left()
                                  .begin_flow()
                                  .map([](float const &value) { return value + 300.0f; })
                                  .receive(this->indicator_count.layout_guide_rect().right().receiver())
                                  .sync());
}

void vu::ui_main::_setup_indicators(main_ptr_t &main, ui::texture &texture) {
    ui::node &root_node = this->renderer.root_node();
    auto const &safe_area_guide_rect = this->renderer.safe_area_layout_guide_rect();

    ui::layout_guide &indicator_0_left_guide = this->_guides.at(0);
    ui::layout_guide &indicator_0_right_guide = this->_guides.at(1);
    ui::layout_guide &indicator_1_left_guide = this->_guides.at(2);
    ui::layout_guide &indicator_1_right_guide = this->_guides.at(3);

    this->_flows.emplace_back(safe_area_guide_rect.left()
                                  .begin_flow()
                                  .combine(safe_area_guide_rect.right().begin_flow())
                                  .map(ui::justify<3>(std::array<float, 3>{100.0f, 1.0f, 100.0f}))
                                  .receive({indicator_0_left_guide.receiver(), indicator_0_right_guide.receiver(),
                                            indicator_1_left_guide.receiver(), indicator_1_right_guide.receiver()})
                                  .sync());

    ui::layout_guide center_y_guide;

    this->_flows.emplace_back(safe_area_guide_rect.top()
                                  .begin_flow()
                                  .combine(this->reference.layout_guide_rect().top().begin_flow())
                                  .map(ui::justify())
                                  .receive(center_y_guide.receiver())
                                  .sync());

    for (auto const &idx : {0, 1}) {
        auto &indicator = this->indicators.at(idx);
        root_node.add_sub_node(indicator.node);
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

        if (idx == 0) {
            this->_flows.emplace_back(indicator_0_left_guide.begin_flow()
                                          .receive(indicator.frame_layout_guide_rect.left().receiver())
                                          .sync());
            this->_flows.emplace_back(indicator_0_right_guide.begin_flow()
                                          .receive(indicator.frame_layout_guide_rect.right().receiver())
                                          .sync());
            this->_flows.emplace_back(make_vertical_flow(indicator_0_left_guide, indicator_0_right_guide,
                                                         center_y_guide, indicator.frame_layout_guide_rect.bottom(),
                                                         indicator.frame_layout_guide_rect.top()));
        } else {
            this->_flows.emplace_back(indicator_1_left_guide.begin_flow()
                                          .receive(indicator.frame_layout_guide_rect.left().receiver())
                                          .sync());
            this->_flows.emplace_back(indicator_1_right_guide.begin_flow()
                                          .receive(indicator.frame_layout_guide_rect.right().receiver())
                                          .sync());
            this->_flows.emplace_back(make_vertical_flow(indicator_1_left_guide, indicator_1_right_guide,
                                                         center_y_guide, indicator.frame_layout_guide_rect.bottom(),
                                                         indicator.frame_layout_guide_rect.top()));
        }
    }
}
