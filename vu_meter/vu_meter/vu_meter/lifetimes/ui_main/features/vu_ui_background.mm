//
//  vu_ui.mm
//

#include "vu_ui_background.hpp"
#include <cpp-utils/fast_each.h>
#include "vu_audio_graph.hpp"
#include "vu_lifetime_accessor.hpp"
#include "vu_ui_color.hpp"
#include "vu_ui_lifetime.hpp"
#include "vu_ui_utils.hpp"

using namespace yas;
using namespace yas::vu;

ui_background::ui_background(ui::view_look *view_look) {
    view_look->background()->set_color(vu::base_color());
}

std::shared_ptr<ui_background> vu::ui_background::make_shared() {
    auto const &ui_lifetime = lifetime_accessor::ui_lifetime();
    auto const &view_look = ui_lifetime->standard->view_look();

    return std::shared_ptr<ui_background>(new ui_background{view_look.get()});
}
