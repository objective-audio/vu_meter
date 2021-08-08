//
//  vu_app.cpp
//

#include "vu_app.h"

using namespace yas;
using namespace yas::vu;

app::app() {
}

std::shared_ptr<app> app::shared() {
    static auto const _app = std::shared_ptr<app>(new app{});
    return _app;
}
