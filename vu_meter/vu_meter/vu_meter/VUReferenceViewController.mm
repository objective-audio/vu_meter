//
//  VUReferenceViewController.m
//

#import "VUReferenceViewController.h"

using namespace yas;

@interface VUReferenceViewController ()

@property (nonatomic, assign) IBOutlet UIStepper *stepper;
@property (nonatomic, assign) IBOutlet UILabel *label;

@end

@implementation VUReferenceViewController {
    vu::main_ptr_t _main;
}

- (void)set_vu_main:(vu::main_ptr_t)main {
    self->_main = main;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _updateLabel];
}

- (IBAction)stepperValueChanged:(UIStepper *)sender {
    self->_main->data.set_reference(sender.value);
    [self _updateLabel];
}

- (void)_updateLabel {
    self.label.text = [NSString stringWithFormat:@"%@ dB", @(self->_main->data.reference())];
}

@end
