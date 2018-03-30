//
//  VUMeterViewController.mm
//

#import "VUMeterViewController.h"
#import "yas_audio.h"

using namespace yas;

namespace yas {
static CGAffineTransform transformForMeter(CGFloat in_value, CGFloat reference) {
    CGFloat const db_value = audio::math::decibel_from_linear(in_value);
    CGFloat const value = audio::math::linear_from_decibel(db_value - reference);

    double const min = audio::math::linear_from_decibel(-20.0);
    double const max = audio::math::linear_from_decibel(3.0);
    double const min_to_one = 1.0 - min;
    double const min_to_max = max - min;
    CGFloat const value1 = (value - min) / min_to_one;
    CGFloat const meterValue = value1 / min_to_max;

    return CGAffineTransformMakeRotation(meterValue * M_PI_2 - M_PI_4);
}
}

@interface VUMeterViewController ()

@property (nonatomic, assign) IBOutlet UISlider *slider;
@property (nonatomic, assign) IBOutlet UIView *needleBaseView;
@property (nonatomic, assign) IBOutlet UIView *db0BaseView;

@property (nonatomic, assign) CADisplayLink *displayLink;

@end

@implementation VUMeterViewController {
    vu::main_ptr_t _main;
    std::size_t _idx;
}

- (void)dealloc {
    [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

    yas_super_dealloc();
}

- (void)set_vu_main:(vu::main_ptr_t)main index:(std::size_t)idx {
    self->_main = main;
    self->_idx = idx;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.db0BaseView.transform = transformForMeter(audio::math::linear_from_decibel(0.0), 0.0);

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

    [self _updateNeedleRotation];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
    //    [self _updateNeedleRotation];
}

- (void)update {
    [self _updateNeedleRotation];
}

- (void)_updateNeedleRotation {
    int32_t const reference = self->_main->data.reference();
    self.needleBaseView.transform = transformForMeter(self->_main->values.at(self->_idx).load(), reference);
}

@end
