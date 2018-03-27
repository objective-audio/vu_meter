//
//  VUReferenceViewController.m
//

#import "VUReferenceViewController.h"

@interface VUReferenceViewController ()

@property (nonatomic, assign) IBOutlet UIStepper *stepper;
@property (nonatomic, assign) IBOutlet UILabel *label;

@end

@implementation VUReferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _updateLabel];
}

- (IBAction)stepperValueChanged:(UIStepper *)sender {
    [self _updateLabel];
}

- (void)_updateLabel {
    self.label.text = [NSString stringWithFormat:@"%@ dB", @(NSInteger(self.stepper.value))];
}

@end
