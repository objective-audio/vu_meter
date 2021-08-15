//
//  vu_app.cpp
//

#include "vu_app.h"

using namespace yas;
using namespace yas::vu;

namespace yas::vu::global {
static std::shared_ptr<app> _app;
}

void app_setup::setup(std::shared_ptr<ui::standard> const &standard) {
    global::_app = std::shared_ptr<app>(new app{standard});
    global::_app->_ui_main = ui_main::make_shared();
}

app::app(std::shared_ptr<ui::standard> const &standard) : main(main::make_shared()), ui_standard(standard) {
}

std::shared_ptr<app> app::shared() {
    return global::_app;
}
