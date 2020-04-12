//
//  vu_indicator.mm
//

#include "vu_ui_indicator.hpp"
#include <audio/yas_audio_umbrella.h>
#include <cpp_utils/yas_fast_each.h>
#include "vu_main.hpp"
#include "vu_ui_color.hpp"
#include "vu_ui_utils.hpp"

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

struct vu::ui_indicator_resource::impl {
    std::weak_ptr<ui::renderer> _weak_renderer;
    chaining::value::holder_ptr<ui::font_atlas_ptr> _font_atlas{
        chaining::value::holder<ui::font_atlas_ptr>::make_shared(nullptr)};
    float _vu_height = 0.0f;

    impl(ui::renderer_ptr const &renderer) : _weak_renderer(renderer) {
    }

    void set_vu_height(float const height) {
        float const rounded_height = std::round(height);
        if (this->_vu_height != rounded_height) {
            this->_vu_height = rounded_height;

            this->_font_atlas->set_value(nullptr);
            this->_create_font_atlas();
        }
    }

   private:
    void _create_font_atlas() {
        auto texture = ui::texture::make_shared({.point_size = {1024, 1024}});
        if (auto renderer = this->_weak_renderer.lock()) {
            texture->sync_scale_from_renderer(renderer);
        }

        float const font_size = constants::number_font_size_rate * this->_vu_height;

        this->_font_atlas->set_value(ui::font_atlas::make_shared(
            {.font_name = "TrebuchetMS-Bold", .font_size = font_size, .words = "0123456789-CH", .texture = texture}));
    }
};

#pragma mark - ui_indicator_resource

vu::ui_indicator_resource::ui_indicator_resource(ui::renderer_ptr const &renderer)
    : _impl(std::make_unique<impl>(renderer)) {
}

void vu::ui_indicator_resource::set_vu_height(float const height) {
    this->_impl->set_vu_height(height);
}

chaining::value::holder_ptr<ui::font_atlas_ptr> const &vu::ui_indicator_resource::font_atlas() {
    return this->_impl->_font_atlas;
}

vu::ui_indicator_resource_ptr vu::ui_indicator_resource::make_shared(ui::renderer_ptr const &renderer) {
    return std::shared_ptr<ui_indicator_resource>(new ui_indicator_resource{renderer});
}

#pragma mark - ui_indicator::impl

struct vu::ui_indicator::impl {
    std::size_t idx;
    ui::node_ptr node = ui::node::make_shared();
    ui::node_ptr _batch_node = ui::node::make_shared();
    ui::rect_plane_ptr base_plane = ui::rect_plane::make_shared(1);
    ui::node_ptr needle_root_node = ui::node::make_shared();
    ui::node_ptr _numbers_root_node = ui::node::make_shared();
    ui::rect_plane_ptr needle = ui::rect_plane::make_shared(1);
    std::vector<ui::node_ptr> gridline_handles;
    std::vector<ui::rect_plane_ptr> gridlines;
    std::vector<ui::node_ptr> number_handles;
    std::vector<ui::strings_ptr> db_numbers;
    ui::strings_ptr ch_number = nullptr;
    ui::layout_guide_point_ptr _ch_number_guide = ui::layout_guide_point::make_shared();

    ui_indicator_resource_ptr _resource = nullptr;

    ui::render_target_ptr _render_target = ui::render_target::make_shared();

    ui::layout_guide_rect_ptr frame_layout_guide_rect = ui::layout_guide_rect::make_shared();

    impl() {
    }

    void setup(std::weak_ptr<ui_indicator> const &weak_indicator, main_ptr_t const &main,
               ui_indicator_resource_ptr const &resource, std::size_t const idx) {
        weak_main_ptr_t weak_main = main;
        this->_weak_main = weak_main;
        this->_resource = resource;
        this->idx = idx;

        // receivers

        this->_update_receiver = chaining::perform_receiver<std::nullptr_t>::make_shared([weak_indicator] {
            if (auto indicator = weak_indicator.lock()) {
                indicator->_impl->_update();
            }
        });

        this->_renderer_receiver = chaining::perform_receiver<ui::renderer_ptr>::make_shared(
            [weak_indicator, observer = chaining::any_observer_ptr{nullptr}](ui::renderer_ptr const &renderer) mutable {
                if (auto indicator = weak_indicator.lock()) {
                    if (renderer) {
                        auto &imp = indicator->_impl;
                        observer = renderer->chain_will_render().send_to(imp->_update_receiver).end();
                        imp->_render_target->sync_scale_from_renderer(renderer);
                    } else {
                        observer = nullptr;
                    }
                }
            });

        this->_layout_receiver =
            chaining::perform_receiver<ui::region>::make_shared([weak_indicator](ui::region const &region) {
                if (auto indicator = weak_indicator.lock()) {
                    indicator->_impl->_layout(region);
                }
            });

        // node

        this->node->attach_position_layout_guides(*this->_node_guide_point);

        this->_observers += this->frame_layout_guide_rect->left()->chain().send_to(this->_node_guide_point->x()).sync();

        this->_observers +=
            this->frame_layout_guide_rect->bottom()->chain().send_to(this->_node_guide_point->y()).sync();

        // batch_node

        this->_batch_node->batch()->set_value(ui::batch::make_shared());
        this->node->add_sub_node(_batch_node);

        // base_plane

        this->base_plane->node()->color()->set_value(vu::indicator_base_color());
        this->_batch_node->add_sub_node(this->base_plane->node());

        this->_observers += this->_base_guide_rect->chain()
                                .perform([weak_indicator](ui::region const &region) {
                                    if (auto indicator = weak_indicator.lock()) {
                                        indicator->_impl->base_plane->data()->set_rect_position(region, 0);
                                    }
                                })
                                .end();

        this->_observers +=
            this->frame_layout_guide_rect->width()->chain().send_to(this->_base_guide_rect->right()).sync();

        this->_observers +=
            this->frame_layout_guide_rect->height()->chain().send_to(this->_base_guide_rect->top()).sync();

        // render_target

        this->_observers += this->_base_guide_rect->chain().send_to(this->_render_target->layout_guide_rect()).sync();
        this->node->render_target()->set_value(this->_render_target);

        // numbers_root_node
        this->_batch_node->add_sub_node(this->_numbers_root_node);

        // needle_root_node
        this->node->add_sub_node(this->needle_root_node);

        // numbers
        for (auto const &param : constants::params) {
            auto &gridline_handle = this->gridline_handles.emplace_back(ui::node::make_shared());
            auto &plane = this->gridlines.emplace_back(ui::rect_plane::make_shared(1));

            auto &number_handle = this->number_handles.emplace_back(ui::node::make_shared());
            ui::strings::args args{
                .text = std::to_string(std::abs(param)), .max_word_count = 3, .alignment = ui::layout_alignment::mid};
            auto &number = this->db_numbers.emplace_back(ui::strings::make_shared(std::move(args)));

            this->_numbers_root_node->add_sub_node(gridline_handle);
            gridline_handle->add_sub_node(plane->node());
            gridline_handle->add_sub_node(number_handle);
            number_handle->add_sub_node(number->rect_plane()->node());

            ui::angle const angle = ui_utils::meter_angle(audio::math::linear_from_decibel(static_cast<float>(param)),
                                                          0.0f, constants::half_angle.degrees);
            gridline_handle->angle()->set_value(angle);
            number_handle->angle()->set_value(-angle);

            if (param > 0) {
                plane->node()->color()->set_value(vu::indicator_over_gridline_color());
                number->rect_plane()->node()->color()->set_value(vu::indicator_over_number_color());
            } else {
                plane->node()->color()->set_value(vu::indicator_gridline_color());
                number->rect_plane()->node()->color()->set_value(vu::indicator_number_color());
            }
        }

        // ch_number

        ui::strings::args ch_number_args{
            .text = "CH-" + std::to_string(idx + 1), .max_word_count = 5, .alignment = ui::layout_alignment::max};
        this->ch_number = ui::strings::make_shared(ch_number_args);
        this->ch_number->rect_plane()->node()->color()->set_value(vu::indicator_ch_color());
        this->ch_number->rect_plane()->node()->attach_position_layout_guides(*this->_ch_number_guide);
        this->node->add_sub_node(ch_number->rect_plane()->node());

        this->_observers += this->frame_layout_guide_rect->chain()
                                .to([](ui::region const &region) {
                                    return ui::point{.x = region.size.width * 0.97f, .y = region.size.height * 0.2f};
                                })
                                .send_to(this->_ch_number_guide)
                                .sync();

        // needle
        this->needle->node()->color()->set_value(vu::indicator_needle_color());
        this->needle_root_node->add_sub_node(this->needle->node());

        // indicator_resource

        this->_resource_observer =
            this->_resource->font_atlas()
                ->chain()
                .perform([weak_indicator](ui::font_atlas_ptr const &atlas) {
                    if (ui_indicator_ptr const indicator = weak_indicator.lock()) {
                        auto &imp = indicator->_impl;
                        float const number_offset = atlas ? (atlas->ascent() + atlas->descent()) * 0.5f : 0.0f;

                        for (auto const &number : imp->db_numbers) {
                            number->set_font_atlas(atlas);
                            number->rect_plane()->node()->position()->set_value({.y = number_offset});
                        }

                        imp->ch_number->set_font_atlas(atlas);
                    }
                })
                .sync();

        // layout_guide
        this->_frame_observer = this->frame_layout_guide_rect->chain().send_to(this->_layout_receiver).end();

        this->_renderer_observer = this->node->chain_renderer().send_to(this->_renderer_receiver).sync();
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
        this->needle_root_node->position()->set_value({.x = needle_root_x, .y = needle_root_y});
        this->needle->data()->set_rect_position(
            {.origin = {.x = -needle_width * 0.5f}, .size = {.width = needle_width, .height = needle_height}}, 0);

        // numbers_root_node
        this->_numbers_root_node->position()->set_value(this->needle_root_node->position()->raw());

        // gridline
        for (auto const &gridline : this->gridlines) {
            ui::node_ptr const &parent = gridline->node()->parent();
            float const gridline_y =
                vu::ui_utils::gridline_y(parent->angle()->raw(), constants::half_angle, gridline_side_y, 0.1f);
            gridline->node()->position()->set_value({.y = gridline_y});
            gridline->data()->set_rect_position({.origin = {.x = -gridline_width * 0.5f, .y = -gridline_height * 0.5f},
                                                 .size = {.width = gridline_width, .height = gridline_height}},
                                                0);
        }

        float const number_side_y = constants::number_y_rate * height;
        for (auto &handle : this->number_handles) {
            ui::node_ptr const parent = handle->parent();
            float const number_y =
                vu::ui_utils::gridline_y(parent->angle()->raw(), constants::half_angle, number_side_y, 0.1f);
            handle->position()->set_value({.y = number_y});
        }
    }

    void _update() {
        if (auto main = this->_weak_main.lock()) {
            auto values = main->values();
            float const value = (this->idx < values.size()) ? values.at(this->idx) : 0.0f;
            ui::angle const angle =
                ui_utils::meter_angle(value, main->data->reference(), constants::half_angle.degrees);
            this->needle->node()->angle()->set_value(angle);
        }
    }

   private:
    chaining::any_observer_ptr _frame_observer = nullptr;
    chaining::any_observer_ptr _resource_observer = nullptr;
    weak_main_ptr_t _weak_main;

    chaining::observer_pool _observers;
    chaining::any_observer_ptr _renderer_observer = nullptr;
    chaining::receiver_ptr<ui::renderer_ptr> _renderer_receiver = nullptr;
    chaining::receiver_ptr<std::nullptr_t> _update_receiver = nullptr;
    chaining::receiver_ptr<ui::region> _layout_receiver = nullptr;
    ui::layout_guide_point_ptr _node_guide_point = ui::layout_guide_point::make_shared();
    ui::layout_guide_rect_ptr _base_guide_rect = ui::layout_guide_rect::make_shared();
};

#pragma mark - ui_indicator

vu::ui_indicator::ui_indicator() : _impl(std::make_unique<impl>()) {
}

void vu::ui_indicator::setup(main_ptr_t const &main, ui_indicator_resource_ptr const &resource, std::size_t const idx) {
    this->_impl->setup(this->_weak_indicator, main, resource, idx);
}

ui::node_ptr const &vu::ui_indicator::node() {
    return this->_impl->node;
}

ui::layout_guide_rect_ptr const &vu::ui_indicator::frame_layout_guide_rect() {
    return this->_impl->frame_layout_guide_rect;
}

vu::ui_indicator_ptr vu::ui_indicator::make_shared() {
    auto shared = std::shared_ptr<ui_indicator>(new ui_indicator{});
    shared->_weak_indicator = shared;
    return shared;
}
