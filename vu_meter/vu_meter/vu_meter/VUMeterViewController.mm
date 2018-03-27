//
//  VUMeterViewController.mm
//

#import "VUMeterViewController.h"

using namespace yas;

@interface VUMeterViewController ()

@end

@implementation VUMeterViewController {
    vu::main_ptr_t _main;
}

- (void)set_vu_main:(vu::main_ptr_t)main {
    self->_main = main;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
