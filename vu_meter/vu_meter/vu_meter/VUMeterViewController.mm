//
//  VUMeterViewController.mm
//

#import "VUMeterViewController.h"

using namespace yas;

@interface VUMeterViewController ()

@property (nonatomic, assign) IBOutlet UISlider *slider;
@property (nonatomic, assign) IBOutlet UIView *needleBaseView;

@end

@implementation VUMeterViewController {
    vu::main_ptr_t _main;
    std::size_t _idx;
}

- (void)set_vu_main:(vu::main_ptr_t)main index:(std::size_t)idx {
    self->_main = main;
    self->_idx = idx;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _updateNeedleRotation];
}

- (IBAction)sliderValueChanged:(UISlider *)slider {
    [self _updateNeedleRotation];
}

- (void)_updateNeedleRotation {
    CGFloat value = self.slider.value;
    self.needleBaseView.transform = CGAffineTransformMakeRotation(self.slider.value * M_PI_2 - M_PI_4);
}

@end
