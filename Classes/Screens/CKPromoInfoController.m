//
//  CKPromoInfoController.m
//  click
//
//  Created by Igor Tetyuev on 10.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKPromoInfoController.h"

@implementation CKPromoInfoController

- (void) loadView
{
    UIWebView *webview = [[UIWebView alloc] init];
    webview.backgroundColor = [UIColor whiteColor];
    self.view = webview;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"promo" withExtension:@"html"];
    NSString *html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [webview loadHTMLString:html baseURL:baseUrl];
    self.title = @"Промо код";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_left_blue"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
