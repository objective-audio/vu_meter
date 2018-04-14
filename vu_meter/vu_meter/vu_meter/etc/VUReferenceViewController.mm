//
//  VUReferenceViewController.m
//

#import "VUReferenceViewController.h"
#import "yas_objc_unowned.h"
#import "vu_main.hpp"
#import "yas_flow_observing.h"

using namespace yas;

namespace yas::vu {
    struct reference_vc {
        vu::main_ptr_t main;
        base data_flow = nullptr;
    };
}

@interface VUReferenceViewController ()

@property (nonatomic, assign) IBOutlet UIStepper *stepper;
@property (nonatomic, assign) IBOutlet UILabel *label;

@end

@implementation VUReferenceViewController {
    vu::reference_vc _cpp;
}

- (void)set_vu_main:(vu::main_ptr_t)main {
    self->_cpp.main = main;

    YASUnownedObject<VUReferenceViewController *> *unowned = [[YASUnownedObject alloc] initWithObject:self];

    self->_cpp.data_flow = begin_flow(self->_cpp.main->data.subject(), vu::data::method::reference_changed)
                               .execute([unowned](vu::data const &) { [[unowned object] _updateLabel]; })
                               .end();
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.stepper.value = self->_cpp.main->data.reference();
    
    [self _updateLabel];
}

- (IBAction)stepperValueChanged:(UIStepper *)sender {
    self->_cpp.main->data.set_reference(sender.value);
}

- (void)_updateLabel {
    self.label.text = [NSString stringWithFormat:@"%@ dB", @(self->_cpp.main->data.reference())];
}

@end
