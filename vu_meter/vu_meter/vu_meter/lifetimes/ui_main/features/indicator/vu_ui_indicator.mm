//
//  vu_indicator.mm
//

#include "vu_ui_indicator.hpp"

#include <audio/yas_audio_umbrella.h>
#include <cpp_utils/yas_fast_each.h>

#include "vu_lifetime_accessor.hpp"
#include "vu_ui_color.hpp"
#include "vu_ui_indicator_constants.h"
#include "vu_ui_lifetime.hpp"
#include "vu_ui_utils.hpp"

using namespace yas;
using namespace yas::vu;

#pragma mark - ui_indicator::impl

struct ui_indicator::impl {
    std::shared_ptr<ui::node> const node = ui::node::make_shared();
    std::shared_ptr<ui::layout_region_guide> const frame_layout_guide = ui::layout_region_guide::make_shared();

    impl(std::shared_ptr<ui::standard> const &standard,
         std::shared_ptr<ui_indicator_resource_for_indicator> const &resource,
         std::shared_ptr<ui_indicator_presenter> const &presenter)
        : _render_target(ui::render_target::make_shared(standard->view_look())),
          _resource(resource),
          _presenter(presenter) {
        // node

        this->node->attach_position_layout_guides(*this->_node_guide_point);

        this->frame_layout_guide->left()
            ->observe([this](float const &value) { this->_node_guide_point->x()->set_value(value); })
            .sync()
            ->add_to(this->_pool);

        this->frame_layout_guide->bottom()
            ->observe([this](float const &value) { this->_node_guide_point->y()->set_value(value); })
            .sync()
            ->add_to(this->_pool);

        // batch_node

        this->_batch_node->set_batch(ui::batch::make_shared());
        this->node->add_sub_node(this->_batch_node);

        // base_plane

        this->_base_plane->node()->set_color(indicator_base_color());
        this->_batch_node->add_sub_node(this->_base_plane->node());

        this->_base_guide_rect
            ->observe([this](ui::region const &region) { this->_base_plane->data()->set_rect_position(region, 0); })
            .end()
            ->add_to(this->_pool);

        this->frame_layout_guide->width()
            ->observe([this](float const &value) { this->_base_guide_rect->right()->set_value(value); })
            .sync()
            ->add_to(this->_pool);

        this->frame_layout_guide->height()
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
        this->node->add_sub_node(this->_needle_root_node);

        // numbers
        for (auto const &param : constants::params) {
            auto &gridline_handle = this->_gridline_handles.emplace_back(ui::node::make_shared());
            auto &plane = this->_gridlines.emplace_back(ui::rect_plane::make_shared(1));

            auto &number_handle = this->_number_handles.emplace_back(ui::node::make_shared());
            ui::strings_args args{
                .text = std::to_string(std::abs(param)), .max_word_count = 3, .alignment = ui::layout_alignment::mid};

            this->_numbers_root_node->add_sub_node(gridline_handle);
            gridline_handle->add_sub_node(plane->node());
            gridline_handle->add_sub_node(number_handle);

            ui::angle const angle = ui_utils::meter_angle(audio::math::linear_from_decibel(static_cast<float>(param)),
                                                          constants::half_angle.degrees);
            gridline_handle->set_angle(angle);
            number_handle->set_angle(-angle);

            if (param > 0) {
                plane->node()->set_color(indicator_over_gridline_color());
            } else {
                plane->node()->set_color(indicator_gridline_color());
            }
        }

        this->frame_layout_guide
            ->observe([this](ui::region const &region) {
                this->_ch_number_guide->set_point(
                    ui::point{.x = region.size.width * 0.97f, .y = region.size.height * 0.2f});
            })
            .sync()
            ->add_to(this->_pool);

        // needle
        this->_needle->node()->set_color(indicator_needle_color());
        this->_needle_root_node->add_sub_node(this->_needle->node());

        // indicator_resource

        this->_resource_observer = this->_resource
                                       ->observe_font_atlas([this](std::shared_ptr<ui::font_atlas> const &atlas) {
                                           this->_replace_font_atlas(atlas);
                                       })
                                       .sync();

        // layout_guide
        this->frame_layout_guide->observe([this](ui::region const &region) { this->_layout(region); })
            .end()
            ->add_to(this->_pool);

        standard->renderer()
            ->observe_will_render(
                [this](auto const &) { this->_needle->node()->set_angle(this->_presenter->meter_angle()); })
            .end()
            ->add_to(this->_pool);
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
        this->_needle_root_node->set_position({.x = needle_root_x, .y = needle_root_y});
        this->_needle->data()->set_rect_position(
            {.origin = {.x = -needle_width * 0.5f}, .size = {.width = needle_width, .height = needle_height}}, 0);

        // numbers_root_node
        this->_numbers_root_node->set_position(this->_needle_root_node->position());

        // gridline
        for (auto const &gridline : this->_gridlines) {
            std::shared_ptr<ui::node> const &parent = gridline->node()->parent();
            float const gridline_y =
                ui_utils::gridline_y(parent->angle(), constants::half_angle, gridline_side_y, 0.1f);
            gridline->node()->set_position({.y = gridline_y});
            gridline->data()->set_rect_position({.origin = {.x = -gridline_width * 0.5f, .y = -gridline_height * 0.5f},
                                                 .size = {.width = gridline_width, .height = gridline_height}},
                                                0);
        }

        float const number_side_y = constants::number_y_rate * height;
        for (auto &handle : this->_number_handles) {
            std::shared_ptr<ui::node> const parent = handle->parent();
            float const number_y = ui_utils::gridline_y(parent->angle(), constants::half_angle, number_side_y, 0.1f);
            handle->set_position({.y = number_y});
        }
    }

    void _replace_font_atlas(std::shared_ptr<ui::font_atlas> const &atlas) {
        if (this->_ch_number) {
            this->_ch_number->rect_plane()->node()->remove_from_super_node();
            this->_ch_number = nullptr;
        }

        for (auto const &db_number : this->_db_numbers) {
            db_number->rect_plane()->node()->remove_from_super_node();
        }
        this->_db_numbers.clear();

        if (!atlas) {
            return;
        }

        // numbers

        float const number_offset = atlas ? (atlas->ascent() + atlas->descent()) * 0.5f : 0.0f;

        auto each = make_fast_each(constants::params.size());
        while (yas_each_next(each)) {
            auto const &idx = yas_each_index(each);

            auto const &param = constants::params.at(idx);
            auto const &number_handle = this->_number_handles.at(idx);

            ui::strings_args args{
                .text = std::to_string(std::abs(param)), .max_word_count = 3, .alignment = ui::layout_alignment::mid};
            auto const &number = this->_db_numbers.emplace_back(ui::strings::make_shared(std::move(args), atlas));
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
            .text = this->_presenter->ch_number_text(), .max_word_count = 5, .alignment = ui::layout_alignment::max};
        this->_ch_number = ui::strings::make_shared(std::move(ch_number_args), atlas);
        auto const &ch_number_node = this->_ch_number->rect_plane()->node();
        ch_number_node->set_color(indicator_ch_color());
        ch_number_node->attach_position_layout_guides(*this->_ch_number_guide);
        this->node->add_sub_node(ch_number_node);
    }

   private:
    std::shared_ptr<ui::render_target> const _render_target;
    std::shared_ptr<ui_indicator_resource_for_indicator> const _resource;
    std::shared_ptr<ui_indicator_presenter> const _presenter;

    std::shared_ptr<ui::node> const _batch_node = ui::node::make_shared();
    std::shared_ptr<ui::rect_plane> const _base_plane = ui::rect_plane::make_shared(1);
    std::shared_ptr<ui::node> const _needle_root_node = ui::node::make_shared();
    std::shared_ptr<ui::node> const _numbers_root_node = ui::node::make_shared();
    std::shared_ptr<ui::rect_plane> const _needle = ui::rect_plane::make_shared(1);
    std::vector<std::shared_ptr<ui::node>> _gridline_handles;
    std::vector<std::shared_ptr<ui::rect_plane>> _gridlines;
    std::vector<std::shared_ptr<ui::node>> _number_handles;
    std::vector<std::shared_ptr<ui::strings>> _db_numbers;
    std::shared_ptr<ui::strings> _ch_number = nullptr;
    std::shared_ptr<ui::layout_point_guide> const _ch_number_guide = ui::layout_point_guide::make_shared();

    observing::cancellable_ptr _resource_observer = nullptr;
    observing::canceller_pool _pool;
    std::shared_ptr<ui::layout_point_guide> const _node_guide_point = ui::layout_point_guide::make_shared();
    std::shared_ptr<ui::layout_region_guide> const _base_guide_rect = ui::layout_region_guide::make_shared();
};

#pragma mark - ui_indicator

ui_indicator::ui_indicator(std::shared_ptr<ui::standard> const &standard,
                           std::shared_ptr<ui_indicator_resource_for_indicator> const &resource,
                           std::shared_ptr<ui_indicator_presenter> const &presenter)
    : _impl(std::make_unique<impl>(standard, resource, presenter)) {
}

std::shared_ptr<ui::node> const &ui_indicator::node() {
    return this->_impl->node;
}

void ui_indicator::set_region(ui::region const region) {
    return this->_impl->frame_layout_guide->set_region(region);
}

std::shared_ptr<ui_indicator> ui_indicator::make_shared(
    std::shared_ptr<ui_indicator_resource_for_indicator> const &resource, std::size_t const idx) {
    auto const &ui_lifetime = lifetime_accessor::ui_lifetime();
    auto const presenter = ui_indicator_presenter::make_shared(idx);
    return std::shared_ptr<ui_indicator>(new ui_indicator{ui_lifetime->standard, resource, presenter});
}
