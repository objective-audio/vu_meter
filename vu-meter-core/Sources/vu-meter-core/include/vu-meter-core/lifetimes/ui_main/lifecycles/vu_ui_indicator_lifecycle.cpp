//
//  vu_ui_indicator_lifecycle.cpp
//

#include "vu_ui_indicator_lifecycle.hpp"

#include <cpp-utils/fast_each.h>

#include <vu-meter-core/lifetimes/ui_indicator/features/vu_ui_indicator.hpp>
#include <vu-meter-core/lifetimes/ui_indicator/vu_ui_indicator_lifetime.hpp>

using namespace yas;
using namespace yas::vu;

std::shared_ptr<ui_indicator_lifecycle> ui_indicator_lifecycle::make_shared() {
    return std::make_shared<ui_indicator_lifecycle>();
}

void ui_indicator_lifecycle::reload(std::size_t const size) {
    for (std::shared_ptr<ui_indicator_lifetime> const &lifetime : this->_lifetimes) {
        lifetime->indicator->clean_up();
    }
    this->_lifetimes.clear();

    std::vector<std::shared_ptr<ui_indicator_lifetime>> lifetimes;

    auto each = make_fast_each(size);
    while (yas_each_next(each)) {
        lifetimes.emplace_back(ui_indicator_lifetime::make_shared(yas_each_index(each)));
    }

    this->_lifetimes = std::move(lifetimes);
}

std::vector<std::shared_ptr<ui_indicator_lifetime>> const &ui_indicator_lifecycle::lifetimes() const {
    return this->_lifetimes;
}
