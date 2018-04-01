//
//  VUReferenceViewController.m
//

#import "VUReferenceViewController.h"
#import "yas_objc_unowned.h"
#import "vu_main.hpp"

using namespace yas;

@interface VUReferenceViewController ()

@property (nonatomic, assign) IBOutlet UIStepper *stepper;
@property (nonatomic, assign) IBOutlet UILabel *label;

@end

@implementation VUReferenceViewController {
    vu::main_ptr_t _main;
    vu::data::observer_t _data_observer;
}

- (void)set_vu_main:(vu::main_ptr_t)main {
    self->_main = main;

    YASUnownedObject<VUReferenceViewController *> *unowned = [[YASUnownedObject alloc] initWithObject:self];

    self->_data_observer = self->_main->data.subject.make_observer(
        vu::data::method::reference_changed, [unowned](auto const &context) { [[unowned object] _updateLabel]; });
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.stepper.value = self->_main->data.reference();
    
    [self _updateLabel];
}

- (IBAction)stepperValueChanged:(UIStepper *)sender {
    self->_main->data.set_reference(sender.value);
}

- (void)_updateLabel {
    self.label.text = [NSString stringWithFormat:@"%@ dB", @(self->_main->data.reference())];
}

@end
