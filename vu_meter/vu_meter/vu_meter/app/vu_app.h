//
//  vu_app.h
//

#pragma once

#include "vu_main.hpp"
#include "vu_ui_main.hpp"

namespace yas::vu {
struct app_setup {
    static void setup();
};

struct app {
    std::shared_ptr<main> const main;

    void set_ui_standard(std::shared_ptr<ui::standard> const &);
    std::shared_ptr<ui::standard> const &ui_standard() const;

    static std::shared_ptr<app> shared();

   private:
    std::shared_ptr<ui::standard> _ui_standard;

    app();

    friend app_setup;
};
}  // namespace yas::vu
