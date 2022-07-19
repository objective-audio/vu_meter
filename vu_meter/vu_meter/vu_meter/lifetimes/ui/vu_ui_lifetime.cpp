//
//  vu_ui_lifetime.cpp
//

#include "vu_ui_lifetime.hpp"

#include "vu_ui_main_lifecycle.hpp"

using namespace yas;
using namespace yas::vu;

std::shared_ptr<ui_lifetime> ui_lifetime::make_shared(std::shared_ptr<ui::standard> const &standard) {
    return std::make_shared<ui_lifetime>(standard);
}

ui_lifetime::ui_lifetime(std::shared_ptr<ui::standard> const &standard)
    : standard(standard), main_lifecycle(ui_main_lifecycle::make_shared()) {
}
