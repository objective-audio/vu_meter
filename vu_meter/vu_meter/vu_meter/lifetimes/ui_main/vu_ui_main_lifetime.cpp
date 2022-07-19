//
//  vu_ui_main_lifetime.cpp
//

#include "vu_ui_main_lifetime.hpp"

using namespace yas;
using namespace yas::vu;

std::shared_ptr<ui_main_lifetime> ui_main_lifetime::make_shared() {
    return std::make_shared<ui_main_lifetime>();
}
