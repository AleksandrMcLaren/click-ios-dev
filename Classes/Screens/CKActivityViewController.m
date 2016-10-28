//
//  CKActivityViewController.m
//  click
//
//  Created by Дрягин Павел on 24.10.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "CKActivityViewController.h"

@interface CKActivityViewController (){
    
}

@end

@implementation CKActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.activityIndicatorView.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicatorView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setActivityIndicatorView:(UIActivityIndicatorView *)activityIndicatorView{
    _activityIndicatorView = activityIndicatorView;
}

#pragma mark CKOperationsProtocol

-(void)beginOperation:(NSString*)operation{
    [self.activityIndicatorView startAnimating];
    [self.continueButton setEnabled:NO];
}

-(void)endOperation:(NSString*)operation{
    [self.activityIndicatorView stopAnimating];
    [self.continueButton setEnabled:YES];
}

- (BOOL)canAutoRotate
{
    return NO;
}

- (void) viewTapped {
    [self dismissKeyboard];
}

-(void)dismissKeyboard{
    
}
@end
