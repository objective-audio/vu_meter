//
//  vu_app.cpp
//

#include "vu_app.h"

using namespace yas;
using namespace yas::vu;

namespace yas::vu::global {
static std::shared_ptr<app> _app;
}

void app_setup::setup() {
    global::_app = std::shared_ptr<app>(new app{});
}

void app::set_ui_standard(std::shared_ptr<ui::standard> const &ui_standard) {
    this->_ui_standard = ui_standard;
}

app::app() : main(main::make_shared()) {
}

std::shared_ptr<ui::standard> const &app::ui_standard() const {
    return this->_ui_standard;
}

std::shared_ptr<app> app::shared() {
    return global::_app;
}
