//
//  vu_app_lifetime.cpp
//

#include "vu_app_lifetime.hpp"

#include "vu_indicator_lifecycle.hpp"
#include "vu_indicator_values.hpp"
#include "vu_main.hpp"
#include "vu_settings.hpp"
#include "vu_ui_lifecycle.hpp"

using namespace yas;
using namespace yas::vu;

std::shared_ptr<app_lifetime> app_lifetime::make_shared() {
    return std::make_shared<app_lifetime>();
}

app_lifetime::app_lifetime()
    : settings(settings::make_shared()),
      indicator_lifecycle(indicator_lifecycle::make_shared()),
      ui_lifecycle(ui_lifecycle::make_shared()),
      indicator_values(indicator_values::make_shared(this->indicator_lifecycle.get())),
      main(main::make_shared(this->indicator_values.get())) {
}
