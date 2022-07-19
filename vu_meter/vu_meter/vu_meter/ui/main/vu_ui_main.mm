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

ui_main::ui_main(std::shared_ptr<ui::view_look> const &view_look) {
    view_look->background()->set_color(vu::base_color());
}

std::shared_ptr<ui_main> vu::ui_main::make_shared() {
    auto const &ui_lifetime = lifetime_accessor::ui_lifetime();
    auto const &view_look = ui_lifetime->standard->view_look();

    return std::shared_ptr<ui_main>(new ui_main{view_look});
}
