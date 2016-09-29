//
//  CKPictureCaptureManager.h
//  click
//
//  Created by Igor Tetyuev on 28.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CKPictureCaptureCompleted)(UIImage* image, UIImage *preview, NSURL *path);

@interface CKPictureCaptureManager : NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) CKPictureCaptureCompleted callback;
@property (nonatomic, assign) UIViewController *controller;
@property (nonatomic, assign) BOOL cameraOnly;
@property (nonatomic, assign) BOOL albumsOnly;

- (void)captureWithCallback:(CKPictureCaptureCompleted)callback;

@end
