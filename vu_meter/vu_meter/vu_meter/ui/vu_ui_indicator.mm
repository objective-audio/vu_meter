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

#pragma mark - ui_indicator::impl

struct vu::ui_indicator::impl : base::impl {
    std::size_t idx;
    ui::node node;
    ui::rect_plane base_plane{1};
    ui::node needle_root_node;
    ui::rect_plane needle{1};
    std::vector<ui::node> gridline_handles;
    std::vector<ui::rect_plane> gridlines;
    ui::font_atlas font_atlas{nullptr};
    std::vector<ui::node> number_handles;
    std::vector<ui::strings> numbers;

    ui::layout_guide_rect frame_layout_guide_rect;

    impl() {
    }

    void setup(ui_indicator &indicator, main_ptr_t &main, std::size_t const idx) {
        auto weak_indicator = to_weak(indicator);
        weak_main_ptr_t weak_main = main;
        this->_weak_main = weak_main;

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

        this->_layout_receiver = flow::receiver<>([weak_indicator] {
            if (auto indicator = weak_indicator.lock()) {
                indicator.impl_ptr<impl>()->_layout();
            }
        });

        this->_remove_font_atlas_receiver = flow::receiver<>([weak_indicator] {
            if (auto indicator = weak_indicator.lock()) {
                indicator.impl_ptr<impl>()->_remove_font_atlas();
            }
        });

        // node

        this->node.attach_position_layout_guides(this->_node_guide_point);

        this->_flows.emplace_back(
            this->frame_layout_guide_rect.left().begin_flow().receive(this->_node_guide_point.x().receiver()).sync());

        this->_flows.emplace_back(
            this->frame_layout_guide_rect.bottom().begin_flow().receive(this->_node_guide_point.y().receiver()).sync());

        this->_node_flow = this->node.subject()
                               .begin_flow(ui::node::method::renderer_changed)
                               .perform([weak_indicator](ui::node const &node) {
                                   if (auto indicator = weak_indicator.lock()) {
                                       auto imp = indicator.impl_ptr<impl>();

                                       if (!imp->font_atlas) {
                                           return;
                                       }

                                       if (ui::texture texture = imp->font_atlas.texture()) {
                                           if (ui::renderer renderer = node.renderer()) {
                                               texture.sync_scale_from_renderer(renderer);
                                           }
                                       }
                                   }
                               })
                               .end();

        // base_plane

        this->base_plane.node().set_color(vu::indicator_base_color());
        this->node.add_sub_node(this->base_plane.node());

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

            this->needle_root_node.add_sub_node(gridline_handle);
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

        // layout_guide
        // 高さが変わったら文字の大きさも変わるのでfont_atlasを作り直す
        this->_frame_flow = this->frame_layout_guide_rect.begin_flow()
                                .receive_null(this->_layout_receiver)
                                .filter([prev_height = this->frame_layout_guide_rect.height().value()](
                                            ui::region const &region) mutable {
                                    if (prev_height != region.size.height) {
                                        prev_height = region.size.height;
                                        return true;
                                    } else {
                                        return false;
                                    }
                                })
                                .receive_null(this->_remove_font_atlas_receiver)
                                .end();

        this->_renderer_flow = this->node.begin_renderer_flow().receive(this->_renderer_receiver).sync();
    }

    void _layout() {
        ui::region const region = this->frame_layout_guide_rect.region();
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

    void _create_font_atlas() {
        if (!this->font_atlas) {
            if (float const height = this->frame_layout_guide_rect.region().size.height; height > 0.0f) {
                ui::texture texture{{.point_size = {1024, 1024}}};
                if (auto renderer = this->node.renderer()) {
                    texture.sync_scale_from_renderer(renderer);
                }

                float const font_size = constants::number_font_size_rate * height;

                this->font_atlas = ui::font_atlas{
                    {.font_name = "TrebuchetMS-Bold", .font_size = font_size, .words = "012357-", .texture = texture}};

                float const number_offset = (this->font_atlas.ascent() + this->font_atlas.descent()) * 0.5;

                for (auto &number : this->numbers) {
                    number.set_font_atlas(this->font_atlas);
                    number.rect_plane().node().set_position({.y = number_offset});
                }
            }
        }
    }

    void _remove_font_atlas() {
        this->font_atlas = nullptr;
        for (auto &number : this->numbers) {
            number.set_font_atlas(nullptr);
        }
    }

    void _update() {
        this->_create_font_atlas();

        if (auto main = this->_weak_main.lock()) {
            ui::angle const angle = ui_utils::meter_angle(main->values.at(this->idx).load(), main->data.reference(),
                                                          constants::half_angle.degrees);
            this->needle.node().set_angle(angle);
        }
    }

   private:
    flow::observer _node_flow = nullptr;
    flow::observer _frame_flow = nullptr;
    weak_main_ptr_t _weak_main;

    std::vector<flow::observer> _flows;
    flow::observer _renderer_flow = nullptr;
    flow::receiver<ui::renderer> _renderer_receiver = nullptr;
    flow::receiver<> _update_receiver = nullptr;
    flow::receiver<> _remove_font_atlas_receiver = nullptr;
    flow::receiver<> _layout_receiver = nullptr;
    ui::layout_guide_point _node_guide_point;
    ui::layout_guide_rect _base_guide_rect;
};

#pragma mark - ui_indicator

vu::ui_indicator::ui_indicator() : base(std::make_shared<impl>()) {
}

vu::ui_indicator::ui_indicator(std::nullptr_t) : base(nullptr) {
}

void vu::ui_indicator::setup(main_ptr_t &main, std::size_t const idx) {
    impl_ptr<impl>()->setup(*this, main, idx);
}

ui::node &vu::ui_indicator::node() {
    return impl_ptr<impl>()->node;
}

ui::layout_guide_rect &vu::ui_indicator::frame_layout_guide_rect() {
    return impl_ptr<impl>()->frame_layout_guide_rect;
}
