//
//  vu_ui_indicator_resource.mm
//

#include "vu_ui_indicator_resource.hpp"
#include <vu-meter-core/lifetimes/ui_indicator/features/vu_ui_indicator_constants.h>
#include <vu-meter-core/lifetimes/global/vu_lifetime_accessor.hpp>
#include <vu-meter-core/lifetimes/ui/vu_ui_lifetime.hpp>

using namespace yas;
using namespace yas::vu;

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

std::shared_ptr<ui::font_atlas> const &ui_indicator_resource::font_atlas() const {
    return this->_impl->_font_atlas->value();
}

observing::syncable ui_indicator_resource::observe_font_atlas(
    std::function<void(std::shared_ptr<ui::font_atlas> const &)> &&handler) {
    return this->_impl->_font_atlas->observe(std::move(handler));
}

std::shared_ptr<ui_indicator_resource> ui_indicator_resource::make_shared() {
    auto const &ui_lifetime = lifetime_accessor::ui_lifetime();
    return std::shared_ptr<ui_indicator_resource>(new ui_indicator_resource{ui_lifetime->standard->view_look()});
}
