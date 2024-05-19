//
//  vu_app_lifetime.cpp
//

#include "vu_app_lifetime.hpp"

#include <vu-meter-core/lifetimes/app/features/vu_audio_device.hpp>
#include <vu-meter-core/lifetimes/app/features/vu_audio_graph.hpp>
#include <vu-meter-core/lifetimes/app/features/vu_indicator_values.hpp>
#include <vu-meter-core/lifetimes/app/features/vu_settings.hpp>
#include <vu-meter-core/lifetimes/app/lifecycles/vu_indicator_lifecycle.hpp>
#include <vu-meter-core/lifetimes/app/lifecycles/vu_ui_lifecycle.hpp>

using namespace yas;
using namespace yas::vu;

std::shared_ptr<app_lifetime> app_lifetime::make_shared() {
    return std::make_shared<app_lifetime>();
}

app_lifetime::app_lifetime()
    : settings(settings::make_shared()),
      audio_device(audio_device::make_shared()),
      indicator_lifecycle(indicator_lifecycle::make_shared()),
      ui_lifecycle(ui_lifecycle::make_shared()),
      indicator_values(indicator_values::make_shared(this->indicator_lifecycle.get())),
      audio_graph(audio_graph::make_shared(this->indicator_values.get(), this->audio_device.get())) {
}
