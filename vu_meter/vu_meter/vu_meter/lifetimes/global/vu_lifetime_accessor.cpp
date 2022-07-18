//
//  vu_lifetime_accessor.cpp
//

#include "vu_lifetime_accessor.hpp"

#include "vu_app_lifecycle.hpp"
#include "vu_app_lifetime.hpp"
#include "vu_indicator_lifecycle.hpp"
#include "vu_indicator_lifetime.hpp"
#include "vu_ui_lifecycle.hpp"
#include "vu_ui_lifetime.hpp"

using namespace yas;
using namespace yas::vu;

static std::shared_ptr<app_lifecycle> const _global_app_lifecycle = app_lifecycle::make_shared();
static std::shared_ptr<indicator_lifetime> const _null_indicator_lifetime = nullptr;

std::shared_ptr<app_lifecycle> const &lifetime_accessor::app_lifecycle() {
    return _global_app_lifecycle;
}

std::shared_ptr<app_lifetime> const &lifetime_accessor::app_lifetime() {
    return _global_app_lifecycle->lifetime();
}

std::shared_ptr<ui_lifetime> const &lifetime_accessor::ui_lifetime() {
    return app_lifetime()->ui_lifecycle->lifetime();
}

std::shared_ptr<indicator_lifetime> const &lifetime_accessor::indicator_lifetime(std::size_t const idx) {
    auto const &lifetimes = app_lifetime()->indicator_lifecycle->lifetimes();

    if (idx < lifetimes.size()) {
        return lifetimes.at(idx);
    } else {
        return _null_indicator_lifetime;
    }
}
