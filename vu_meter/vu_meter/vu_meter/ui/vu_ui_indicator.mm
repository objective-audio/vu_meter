//
//  vu_indicator.mm
//

#include "vu_ui_indicator.hpp"
#include "vu_main.hpp"
#include "vu_ui_color.hpp"
#include "vu_ui_utils.hpp"
#include "yas_audio.h"
#include "yas_fast_each.h"

using namespace yas;

namespace yas::vu {
namespace constants {
    static float constexpr needle_root_x_rate = 1.0f;
    static float constexpr needle_root_y_rate = -0.2f;
    static float constexpr needle_height_rate = 1.0f;
    static float constexpr needle_width_rate = 0.01f;
    static float constexpr gridline_y_rate = 1.0f;
    static float constexpr gridline_height_rate = 0.1f;
    static float constexpr gridline_width_rate = gridline_height_rate * 0.15f;
    static float constexpr number_y_rate = 1.15f;
    static float constexpr number_font_size_rate = 1.0f / 8.0f;
    static ui::angle constexpr half_angle{.degrees = 50.0f};

    static std::array<int32_t, 11> params{-20, -10, -7, -5, -3, -2, -1, 0, 1, 2, 3};
}
}

#pragma mark - ui_indicator_resource::impl

struct vu::ui_indicator_resource::impl : base::impl {
    weak<ui::renderer> _weak_renderer;
    property<ui::font_atlas> _font_atlas{{.value = nullptr}};
    float _vu_height = 0.0f;

    impl(ui::renderer &renderer) : _weak_renderer(renderer) {
    }

    void set_vu_height(float const height) {
        float const rounded_height = std::round(height);
        if (this->_vu_height != rounded_height) {
            this->_vu_height = rounded_height;

            this->_font_atlas.set_value(ui::font_atlas{nullptr});
            this->_create_font_atlas();
        }
    }

   private:
    void _create_font_atlas() {
        ui::texture texture{{.point_size = {1024, 1024}}};
        if (auto renderer = this->_weak_renderer.lock()) {
            texture.sync_scale_from_renderer(renderer);
        }

        float const font_size = constants::number_font_size_rate * this->_vu_height;

        this->_font_atlas.set_value(ui::font_atlas{
            {.font_name = "TrebuchetMS-Bold", .font_size = font_size, .words = "012357-", .texture = texture}});
    }
};

#pragma mark - ui_indicator_resource

vu::ui_indicator_resource::ui_indicator_resource(ui::renderer &renderer) : base(std::make_shared<impl>(renderer)) {
}

vu::ui_indicator_resource::ui_indicator_resource(std::nullptr_t) : base(nullptr) {
}

void vu::ui_indicator_resource::set_vu_height(float const height) {
    impl_ptr<impl>()->set_vu_height(height);
}

ui::font_atlas &vu::ui_indicator_resource::font_atlas() {
    return impl_ptr<impl>()->_font_atlas.value();
}

flow::node<ui::font_atlas> vu::ui_indicator_resource::begin_font_atlas_flow() {
    return impl_ptr<impl>()->_font_atlas.begin_value_flow();
}

#pragma mark - ui_indicator::impl

struct vu::ui_indicator::impl : base::impl {
    std::size_t idx;
    ui::node node;
    ui::node _batch_node;
    ui::rect_plane base_plane{1};
    ui::node needle_root_node;
    ui::node _numbers_root_node;
    ui::rect_plane needle{1};
    std::vector<ui::node> gridline_handles;
    std::vector<ui::rect_plane> gridlines;
    std::vector<ui::node> number_handles;
    std::vector<ui::strings> numbers;

    ui_indicator_resource _resource = nullptr;

    ui::render_target _render_target;

    ui::layout_guide_rect frame_layout_guide_rect;

    impl() {
    }

    void setup(ui_indicator &indicator, main_ptr_t &main, ui_indicator_resource &&resource, std::size_t const idx) {
        auto weak_indicator = to_weak(indicator);
        weak_main_ptr_t weak_main = main;
        this->_weak_main = weak_main;
        this->_resource = resource;
        this->idx = idx;

        // receivers

        this->_update_receiver = flow::receiver<>([weak_indicator] {
            if (auto indicator = weak_indicator.lock()) {
                indicator.impl_ptr<impl>()->_update();
            }
        });

        this->_renderer_receiver = flow::receiver<ui::renderer>([weak_indicator,
                                                                 will_render_flow = flow::observer{nullptr}](
                                                                    ui::renderer const &renderer) mutable {
            if (auto indicator = weak_indicator.lock()) {
                if (renderer) {
                    will_render_flow =
                        renderer.begin_will_render_flow().receive(indicator.impl_ptr<impl>()->_update_receiver).end();
                } else {
                    will_render_flow = nullptr;
                }
            }
        });

        this->_layout_receiver = flow::receiver<ui::region>([weak_indicator](ui::region const &region) {
            if (auto indicator = weak_indicator.lock()) {
                indicator.impl_ptr<impl>()->_layout(region);
            }
        });

        // node

        this->node.attach_position_layout_guides(this->_node_guide_point);

        this->_flows.emplace_back(
            this->frame_layout_guide_rect.left().begin_flow().receive(this->_node_guide_point.x().receiver()).sync());

        this->_flows.emplace_back(
            this->frame_layout_guide_rect.bottom().begin_flow().receive(this->_node_guide_point.y().receiver()).sync());

        // batch_node

        this->_batch_node.set_batch(ui::batch{});
        this->node.add_sub_node(_batch_node);

        // base_plane

        this->base_plane.node().set_color(vu::indicator_base_color());
        this->_batch_node.add_sub_node(this->base_plane.node());

        this->_flows.emplace_back(this->_base_guide_rect.begin_flow()
                                      .perform([weak_indicator](ui::region const &region) {
                                          if (auto indicator = weak_indicator.lock()) {
                                              indicator.impl_ptr<impl>()->base_plane.data().set_rect_position(region,
                                                                                                              0);
                                          }
                                      })
                                      .end());

        this->_flows.emplace_back(this->frame_layout_guide_rect.width()
                                      .begin_flow()
                                      .receive(this->_base_guide_rect.right().receiver())
                                      .sync());

        this->_flows.emplace_back(this->frame_layout_guide_rect.height()
                                      .begin_flow()
                                      .receive(this->_base_guide_rect.top().receiver())
                                      .sync());

        // render_target

        this->_flows.emplace_back(
            this->_base_guide_rect.begin_flow().receive(this->_render_target.layout_guide_rect().receiver()).sync());
        this->node.set_render_target(this->_render_target);

        // numbers_root_node
        this->_batch_node.add_sub_node(this->_numbers_root_node);

        // needle_root_node
        this->node.add_sub_node(this->needle_root_node);

        // numbers
        for (auto const &param : constants::params) {
            auto &gridline_handle = this->gridline_handles.emplace_back();
            auto &plane = this->gridlines.emplace_back(1);

            auto &number_handle = this->number_handles.emplace_back();
            ui::strings::args args{
                .text = std::to_string(std::abs(param)), .max_word_count = 3, .alignment = ui::layout_alignment::mid};
            auto &number = this->numbers.emplace_back(std::move(args));

            this->_numbers_root_node.add_sub_node(gridline_handle);
            gridline_handle.add_sub_node(plane.node());
            gridline_handle.add_sub_node(number_handle);
            number_handle.add_sub_node(number.rect_plane().node());

            ui::angle const angle = ui_utils::meter_angle(audio::math::linear_from_decibel(static_cast<float>(param)),
                                                          0.0f, constants::half_angle.degrees);
            gridline_handle.set_angle(angle);
            number_handle.set_angle(-angle);

            if (param > 0) {
                plane.node().set_color(vu::indicator_over_gridline_color());
                number.rect_plane().node().set_color(vu::indicator_over_number_color());
            } else {
                plane.node().set_color(vu::indicator_gridline_color());
                number.rect_plane().node().set_color(vu::indicator_number_color());
            }
        }

        // needle
        this->needle.node().set_color(vu::indicator_needle_color());
        this->needle_root_node.add_sub_node(this->needle.node());

        // indicator_resource

        this->_resource_flow = this->_resource.begin_font_atlas_flow()
                                   .perform([weak_indicator](ui::font_atlas const &atlas) {
                                       if (ui_indicator indicator = weak_indicator.lock()) {
                                           auto imp = indicator.impl_ptr<impl>();
                                           float const number_offset =
                                               atlas ? (atlas.ascent() + atlas.descent()) * 0.5f : 0.0f;

                                           for (auto &number : imp->numbers) {
                                               number.set_font_atlas(atlas);
                                               number.rect_plane().node().set_position({.y = number_offset});
                                           }
                                       }
                                   })
                                   .sync();

        // layout_guide
        this->_frame_flow = this->frame_layout_guide_rect.begin_flow().receive(this->_layout_receiver).end();

        this->_renderer_flow = this->node.begin_renderer_flow().receive(this->_renderer_receiver).sync();
    }

    void _layout(ui::region const &region) {
        ui::size const size = region.size;
        float const width = size.width;
        float const height = size.height;
        if (width <= 0.0f || height <= 0.0f) {
            return;
        }

        float const needle_root_x = constants::needle_root_x_rate * height;
        float const needle_root_y = constants::needle_root_y_rate * height;
        float const needle_height = constants::needle_height_rate * height;
        float const needle_width = constants::needle_width_rate * height;
        float const gridline_side_y = constants::gridline_y_rate * height;
        float const gridline_height = constants::gridline_height_rate * height;
        float const gridline_width = constants::gridline_width_rate * height;

        // needle
        this->needle_root_node.set_position({.x = needle_root_x, .y = needle_root_y});
        this->needle.data().set_rect_position(
            {.origin = {.x = -needle_width * 0.5f}, .size = {.width = needle_width, .height = needle_height}}, 0);

        // numbers_root_node
        this->_numbers_root_node.set_position(this->needle_root_node.position());

        // gridline
        for (auto &gridline : this->gridlines) {
            ui::node const parent = gridline.node().parent();
            float const gridline_y =
                vu::ui_utils::gridline_y(parent.angle(), constants::half_angle, gridline_side_y, 0.1f);
            gridline.node().set_position({.y = gridline_y});
            gridline.data().set_rect_position({.origin = {.x = -gridline_width * 0.5f, .y = -gridline_height * 0.5f},
                                               .size = {.width = gridline_width, .height = gridline_height}},
                                              0);
        }

        float const number_side_y = constants::number_y_rate * height;
        for (auto &handle : this->number_handles) {
            ui::node const parent = handle.parent();
            float const number_y = vu::ui_utils::gridline_y(parent.angle(), constants::half_angle, number_side_y, 0.1f);
            handle.set_position({.y = number_y});
        }
    }

    void _update() {
        if (auto main = this->_weak_main.lock()) {
            float const value = (this->idx < main->values.size()) ? main->values.at(this->idx).load() : 0.0f;
            ui::angle const angle = ui_utils::meter_angle(value, main->data.reference(), constants::half_angle.degrees);
            this->needle.node().set_angle(angle);
        }
    }

   private:
    flow::observer _frame_flow = nullptr;
    flow::observer _resource_flow = nullptr;
    weak_main_ptr_t _weak_main;

    std::vector<flow::observer> _flows;
    flow::observer _renderer_flow = nullptr;
    flow::receiver<ui::renderer> _renderer_receiver = nullptr;
    flow::receiver<> _update_receiver = nullptr;
    flow::receiver<ui::region> _layout_receiver = nullptr;
    ui::layout_guide_point _node_guide_point;
    ui::layout_guide_rect _base_guide_rect;
};

#pragma mark - ui_indicator

vu::ui_indicator::ui_indicator() : base(std::make_shared<impl>()) {
}

vu::ui_indicator::ui_indicator(std::nullptr_t) : base(nullptr) {
}

void vu::ui_indicator::setup(main_ptr_t &main, ui_indicator_resource resource, std::size_t const idx) {
    impl_ptr<impl>()->setup(*this, main, std::move(resource), idx);
}

ui::node &vu::ui_indicator::node() {
    return impl_ptr<impl>()->node;
}

ui::layout_guide_rect &vu::ui_indicator::frame_layout_guide_rect() {
    return impl_ptr<impl>()->frame_layout_guide_rect;
}
