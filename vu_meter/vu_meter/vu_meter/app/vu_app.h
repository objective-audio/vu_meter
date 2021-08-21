//
//  vu_app.h
//

#pragma once

#include "vu_main.hpp"
#include "vu_ui_main.hpp"

namespace yas::vu {
struct app_setup {
    static void setup_global();
};

struct app {
    std::shared_ptr<main> const main;

    void set_ui_standard(std::shared_ptr<ui::standard> const &);
    [[nodiscard]] std::shared_ptr<ui::standard> const &ui_standard() const;

    [[nodiscard]] static std::shared_ptr<app> make_shared();
    [[nodiscard]] static std::shared_ptr<app> global();

   private:
    std::shared_ptr<ui::standard> _ui_standard;

    app(std::shared_ptr<vu::main> const &);

    friend app_setup;
};
}  // namespace yas::vu
