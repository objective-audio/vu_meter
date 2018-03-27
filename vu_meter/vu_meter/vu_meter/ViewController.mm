//
//  ViewController.m
//

#import "ViewController.h"
#import "VUReferenceViewController.h"
#import "VUMeterViewController.h"

using namespace yas;

@interface ViewController ()

@end

@implementation ViewController {
    vu::main_ptr_t _main;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[VUReferenceViewController class]]) {
        VUReferenceViewController *controller = segue.destinationViewController;
        [controller set_vu_main:self->_main];
    } else if ([segue.destinationViewController isKindOfClass:[VUMeterViewController class]]) {
        VUMeterViewController *controller = segue.destinationViewController;
        [controller set_vu_main:self->_main];
    }
}

- (void)set_vu_main:(vu::main_ptr_t)main {
    self->_main = main;
}

@end
