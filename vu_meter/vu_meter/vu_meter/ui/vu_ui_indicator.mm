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
using namespace yas::vu;

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
}  // namespace constants
}  // namespace yas::vu

#pragma mark - ui_indicator_resource::impl

struct ui_indicator_resource::impl {
    std::weak_ptr<ui::view_look> _weak_view_look;
    observing::value::holder_ptr<std::shared_ptr<ui::font_atlas>> _font_atlas{
        observing::value::holder<std::shared_ptr<ui::font_atlas>>::make_shared(nullptr)};
    float _vu_height = 0.0f;

    impl(std::shared_ptr<ui::view_look> const &view_look) : _weak_view_look(view_look) {
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
        auto view_look = this->_weak_view_look.lock();
        if (!view_look) {
            return;
        }

        auto texture = ui::texture::make_shared({.point_size = {1024, 1024}}, view_look);

        float const font_size = constants::number_font_size_rate * this->_vu_height;

        this->_font_atlas->set_value(ui::font_atlas::make_shared(
            {.font_name = "TrebuchetMS-Bold", .font_size = font_size, .words = "0123456789-CH"}, texture));
    }
};

#pragma mark - ui_indicator_resource

ui_indicator_resource::ui_indicator_resource(std::shared_ptr<ui::view_look> const &view_look)
    : _impl(std::make_unique<impl>(view_look)) {
}

void ui_indicator_resource::set_vu_height(float const height) {
    this->_impl->set_vu_height(height);
}

observing::value::holder_ptr<std::shared_ptr<ui::font_atlas>> const &ui_indicator_resource::font_atlas() {
    return this->_impl->_font_atlas;
}

ui_indicator_resource_ptr ui_indicator_resource::make_shared(std::shared_ptr<ui::view_look> const &view_look) {
    return std::shared_ptr<ui_indicator_resource>(new ui_indicator_resource{view_look});
}

#pragma mark - ui_indicator::impl

struct ui_indicator::impl {
    std::shared_ptr<ui::standard> const &_standard;

    std::size_t idx;
    std::shared_ptr<ui::node> node = ui::node::make_shared();
    std::shared_ptr<ui::node> _batch_node = ui::node::make_shared();
    std::shared_ptr<ui::rect_plane> base_plane = ui::rect_plane::make_shared(1);
    std::shared_ptr<ui::node> needle_root_node = ui::node::make_shared();
    std::shared_ptr<ui::node> _numbers_root_node = ui::node::make_shared();
    std::shared_ptr<ui::rect_plane> needle = ui::rect_plane::make_shared(1);
    std::vector<std::shared_ptr<ui::node>> gridline_handles;
    std::vector<std::shared_ptr<ui::rect_plane>> gridlines;
    std::vector<std::shared_ptr<ui::node>> number_handles;
    std::vector<std::shared_ptr<ui::strings>> db_numbers;
    std::shared_ptr<ui::strings> ch_number = nullptr;
    std::shared_ptr<ui::layout_point_guide> _ch_number_guide = ui::layout_point_guide::make_shared();

    ui_indicator_resource_ptr _resource = nullptr;

    std::shared_ptr<ui::render_target> const _render_target;

    std::shared_ptr<ui::layout_region_guide> frame_layout_guide_rect = ui::layout_region_guide::make_shared();

    impl(std::shared_ptr<ui::standard> const &standard)
        : _standard(standard), _render_target(ui::render_target::make_shared(standard->view_look())) {
    }

    void setup(std::weak_ptr<ui_indicator> const &weak_indicator, main_ptr_t const &main,
               ui_indicator_resource_ptr const &resource, std::size_t const idx) {
        weak_main_ptr_t weak_main = main;
        this->_weak_main = weak_main;
        this->_resource = resource;
        this->idx = idx;

        // node

        this->node->attach_position_layout_guides(*this->_node_guide_point);

        this->frame_layout_guide_rect->left()
            ->observe([this](float const &value) { this->_node_guide_point->x()->set_value(value); })
            .sync()
            ->add_to(this->_pool);

        this->frame_layout_guide_rect->bottom()
            ->observe([this](float const &value) { this->_node_guide_point->y()->set_value(value); })
            .sync()
            ->add_to(this->_pool);

        // batch_node

        this->_batch_node->set_batch(ui::batch::make_shared());
        this->node->add_sub_node(this->_batch_node);

        // base_plane

        this->base_plane->node()->set_color(indicator_base_color());
        this->_batch_node->add_sub_node(this->base_plane->node());

        this->_base_guide_rect
            ->observe([weak_indicator](ui::region const &region) {
                if (auto indicator = weak_indicator.lock()) {
                    indicator->_impl->base_plane->data()->set_rect_position(region, 0);
                }
            })
            .end()
            ->add_to(this->_pool);

        this->frame_layout_guide_rect->width()
            ->observe([this](float const &value) { this->_base_guide_rect->right()->set_value(value); })
            .sync()
            ->add_to(this->_pool);

        this->frame_layout_guide_rect->height()
            ->observe([this](float const &value) { this->_base_guide_rect->top()->set_value(value); })
            .sync()
            ->add_to(this->_pool);

        // render_target

        this->_base_guide_rect
            ->observe([this](ui::region const &region) { this->_render_target->layout_guide()->set_region(region); })
            .sync()
            ->add_to(this->_pool);
        this->node->set_render_target(this->_render_target);

        // numbers_root_node
        this->_batch_node->add_sub_node(this->_numbers_root_node);

        // needle_root_node
        this->node->add_sub_node(this->needle_root_node);

        // numbers
        for (auto const &param : constants::params) {
            auto &gridline_handle = this->gridline_handles.emplace_back(ui::node::make_shared());
            auto &plane = this->gridlines.emplace_back(ui::rect_plane::make_shared(1));

            auto &number_handle = this->number_handles.emplace_back(ui::node::make_shared());
            ui::strings_args args{
                .text = std::to_string(std::abs(param)), .max_word_count = 3, .alignment = ui::layout_alignment::mid};

            this->_numbers_root_node->add_sub_node(gridline_handle);
            gridline_handle->add_sub_node(plane->node());
            gridline_handle->add_sub_node(number_handle);

            ui::angle const angle = ui_utils::meter_angle(audio::math::linear_from_decibel(static_cast<float>(param)),
                                                          0.0f, constants::half_angle.degrees);
            gridline_handle->set_angle(angle);
            number_handle->set_angle(-angle);

            if (param > 0) {
                plane->node()->set_color(indicator_over_gridline_color());
            } else {
                plane->node()->set_color(indicator_gridline_color());
            }
        }

        this->frame_layout_guide_rect
            ->observe([this](ui::region const &region) {
                this->_ch_number_guide->set_point(
                    ui::point{.x = region.size.width * 0.97f, .y = region.size.height * 0.2f});
            })
            .sync()
            ->add_to(this->_pool);

        // needle
        this->needle->node()->set_color(indicator_needle_color());
        this->needle_root_node->add_sub_node(this->needle->node());

        // indicator_resource

        this->_resource_observer = this->_resource->font_atlas()
                                       ->observe([weak_indicator](std::shared_ptr<ui::font_atlas> const &atlas) {
                                           if (ui_indicator_ptr const indicator = weak_indicator.lock()) {
                                               indicator->_impl->_set_font_atlas(atlas);
                                           }
                                       })
                                       .sync();

        // layout_guide
        this->frame_layout_guide_rect
            ->observe([weak_indicator](ui::region const &region) {
                if (auto indicator = weak_indicator.lock()) {
                    indicator->_impl->_layout(region);
                }
            })
            .end()
            ->add_to(this->_pool);

        if (auto const indicator = weak_indicator.lock()) {
            this->_standard->renderer()
                ->observe_will_render([weak_indicator](auto const &) {
                    if (auto indicator = weak_indicator.lock()) {
                        indicator->_impl->_update();
                    }
                })
                .end()
                ->add_to(this->_pool);
        }
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
        this->needle_root_node->set_position({.x = needle_root_x, .y = needle_root_y});
        this->needle->data()->set_rect_position(
            {.origin = {.x = -needle_width * 0.5f}, .size = {.width = needle_width, .height = needle_height}}, 0);

        // numbers_root_node
        this->_numbers_root_node->set_position(this->needle_root_node->position());

        // gridline
        for (auto const &gridline : this->gridlines) {
            std::shared_ptr<ui::node> const &parent = gridline->node()->parent();
            float const gridline_y =
                ui_utils::gridline_y(parent->angle(), constants::half_angle, gridline_side_y, 0.1f);
            gridline->node()->set_position({.y = gridline_y});
            gridline->data()->set_rect_position({.origin = {.x = -gridline_width * 0.5f, .y = -gridline_height * 0.5f},
                                                 .size = {.width = gridline_width, .height = gridline_height}},
                                                0);
        }

        float const number_side_y = constants::number_y_rate * height;
        for (auto &handle : this->number_handles) {
            std::shared_ptr<ui::node> const parent = handle->parent();
            float const number_y = ui_utils::gridline_y(parent->angle(), constants::half_angle, number_side_y, 0.1f);
            handle->set_position({.y = number_y});
        }
    }

    void _update() {
        if (auto main = this->_weak_main.lock()) {
            auto values = main->values();
            float const value = (this->idx < values.size()) ? values.at(this->idx) : 0.0f;
            ui::angle const angle =
                ui_utils::meter_angle(value, main->data->reference(), constants::half_angle.degrees);
            this->needle->node()->set_angle(angle);
        }
    }

    void _set_font_atlas(std::shared_ptr<ui::font_atlas> const &atlas) {
        if (this->ch_number) {
            this->ch_number->rect_plane()->node()->remove_from_super_node();
            this->ch_number = nullptr;
        }

        for (auto const &db_number : this->db_numbers) {
            db_number->rect_plane()->node()->remove_from_super_node();
        }
        this->db_numbers.clear();

        if (!atlas) {
            return;
        }

        // numbers

        float const number_offset = atlas ? (atlas->ascent() + atlas->descent()) * 0.5f : 0.0f;

        auto each = make_fast_each(constants::params.size());
        while (yas_each_next(each)) {
            auto const &idx = yas_each_index(each);

            auto const &param = constants::params.at(idx);
            auto const &number_handle = this->number_handles.at(idx);

            ui::strings_args args{
                .text = std::to_string(std::abs(param)), .max_word_count = 3, .alignment = ui::layout_alignment::mid};
            auto const &number = this->db_numbers.emplace_back(ui::strings::make_shared(std::move(args), atlas));
            auto const &node = number->rect_plane()->node();

            node->set_position({.y = number_offset});

            number_handle->add_sub_node(node);

            if (param > 0) {
                node->set_color(indicator_over_number_color());
            } else {
                node->set_color(indicator_number_color());
            }
        }

        // ch_number

        ui::strings_args ch_number_args{
            .text = "CH-" + std::to_string(idx + 1), .max_word_count = 5, .alignment = ui::layout_alignment::max};
        this->ch_number = ui::strings::make_shared(std::move(ch_number_args), atlas);
        auto const &ch_number_node = this->ch_number->rect_plane()->node();
        ch_number_node->set_color(indicator_ch_color());
        ch_number_node->attach_position_layout_guides(*this->_ch_number_guide);
        this->node->add_sub_node(ch_number_node);
    }

   private:
    observing::cancellable_ptr _frame_observer = nullptr;
    observing::cancellable_ptr _resource_observer = nullptr;
    weak_main_ptr_t _weak_main;

    observing::canceller_pool _pool;
    std::shared_ptr<ui::layout_point_guide> _node_guide_point = ui::layout_point_guide::make_shared();
    std::shared_ptr<ui::layout_region_guide> _base_guide_rect = ui::layout_region_guide::make_shared();
};

#pragma mark - ui_indicator

ui_indicator::ui_indicator(std::shared_ptr<ui::standard> const &standard) : _impl(std::make_unique<impl>(standard)) {
}

void ui_indicator::setup(main_ptr_t const &main, ui_indicator_resource_ptr const &resource, std::size_t const idx) {
    this->_impl->setup(this->_weak_indicator, main, resource, idx);
}

std::shared_ptr<ui::node> const &ui_indicator::node() {
    return this->_impl->node;
}

std::shared_ptr<ui::layout_region_guide> const &ui_indicator::frame_layout_guide_rect() {
    return this->_impl->frame_layout_guide_rect;
}

ui_indicator_ptr ui_indicator::make_shared(std::shared_ptr<ui::standard> const &standard) {
    auto shared = std::shared_ptr<ui_indicator>(new ui_indicator{standard});
    shared->_weak_indicator = shared;
    return shared;
}
