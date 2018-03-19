//
//  vu_main.mm
//

#include "vu_main.hpp"
#include <iostream>

using namespace yas;

void vu::main::setup() {
    NSError *error = nil;

    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error]) {
        NSLog(@"error : %@", error);
        return;
    }

    double const sample_rate = this->au_input.au_io().device_sample_rate();
    audio::format format{{.sample_rate = sample_rate, .channel_count = 2}};
    this->manager.connect(this->au_input.au_io().au().node(), this->input_tap.node(), format);

    this->input_tap.set_render_handler([](auto args) mutable {
#warning todo
    });

    if (auto result = this->manager.start_render(); !result) {
        std::cout << "error : " << result.error() << std::endl;
    }
}
