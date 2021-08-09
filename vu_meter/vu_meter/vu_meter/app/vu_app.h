//
//  vu_app.h
//

#pragma once

#include "vu_main.hpp"
#include "vu_ui_main.hpp"

namespace yas::vu {
struct app {
    std::shared_ptr<main> const main = main::make_shared();
    std::shared_ptr<ui::standard> ui_standard = nullptr;
    std::shared_ptr<ui_main> ui_main = nullptr;

    static std::shared_ptr<app> shared();

   private:
    app();
};

}  // namespace yas::vu
