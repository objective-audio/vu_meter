//
//  vu_app.h
//

#pragma once

#include "vu_main.hpp"
#include "vu_ui_main.hpp"

namespace yas::vu {
struct app_setup {
    static void setup(std::shared_ptr<ui::standard> const &);
};

struct app {
    std::shared_ptr<main> const main = main::make_shared();
    std::shared_ptr<ui::standard> const ui_standard;

    static std::shared_ptr<app> shared();

   private:
    std::shared_ptr<vu::ui_main> _ui_main = nullptr;

    app(std::shared_ptr<ui::standard> const &);

    friend app_setup;
};
}  // namespace yas::vu
