//
//  vu_ui.mm
//

#include "vu_ui_main.hpp"
#include <cpp_utils/yas_fast_each.h>
#include "vu_audio_graph.hpp"
#include "vu_lifetime_accessor.hpp"
#include "vu_ui_color.hpp"
#include "vu_ui_indicator_container.hpp"
#include "vu_ui_lifetime.hpp"
#include "vu_ui_utils.hpp"

using namespace yas;
using namespace yas::vu;

namespace yas::vu {
static float constexpr padding = 4.0f;
}

ui_main::ui_main(std::shared_ptr<ui::view_look> const &view_look,
                 std::shared_ptr<ui_indicator_container_for_ui_main> const &container,
                 std::shared_ptr<ui_main_presenter> const &presenter)
    : _indicator_container(container), _presenter(presenter) {
    view_look->background()->set_color(presenter->background_color());

    view_look->safe_area_layout_guide()
        ->observe([this](ui::region const &region) {
            ui::region_insets const insets{
                .left = vu::padding, .right = -vu::padding, .bottom = vu::padding, .top = -vu::padding};
            this->_indicator_container->set_frame(region + insets);
        })
        .sync()
        ->add_to(this->_pool);
}

std::shared_ptr<ui_main> vu::ui_main::make_shared() {
    auto const &ui_lifetime = lifetime_accessor::ui_lifetime();
    auto const &view_look = ui_lifetime->standard->view_look();

    auto const container = ui_indicator_container::make_shared();
    auto const presenter = ui_main_presenter::make_shared();

    return std::shared_ptr<ui_main>(new ui_main{view_look, container, presenter});
}
