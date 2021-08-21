//
//  vu_app.cpp
//

#include "vu_app.h"

using namespace yas;
using namespace yas::vu;

namespace yas::vu::global {
static std::shared_ptr<app> _app;
}

void app_setup::setup_global() {
    global::_app = app::make_shared();
}

void app::set_ui_standard(std::shared_ptr<ui::standard> const &ui_standard) {
    this->_ui_standard = ui_standard;
}

app::app(std::shared_ptr<vu::main> const &main) : main(main) {
}

std::shared_ptr<ui::standard> const &app::ui_standard() const {
    return this->_ui_standard;
}

std::shared_ptr<app> app::make_shared() {
    return std::shared_ptr<app>(new app{vu::main::make_shared()});
}

std::shared_ptr<app> app::global() {
    return global::_app;
}
