//
//  CKPictureCaptureManager.m
//  click
//
//  Created by Igor Tetyuev on 28.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKPictureCaptureManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation CKPictureCaptureManager

- (void)takePhotoWithSource:(UIImagePickerControllerSourceType)source
{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = source;
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:source];
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [self.controller presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[ALAssetsLibrary new] assetForURL:info[UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        if (!image)
        {
            image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        }
        UIImage *preview = [UIImage imageWithCGImage:asset.thumbnail];
        self.callback(image, preview, [info objectForKey:UIImagePickerControllerMediaURL]);
    } failureBlock:^(NSError *error) {
        // handle error
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)captureWithCallback:(CKPictureCaptureCompleted)callback
{
    self.callback = callback;
    UIAlertController *photoPicker = [UIAlertController alertControllerWithTitle:nil
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIImagePickerControllerSourceType lastSource = 0;
    for (NSArray *i in @[
                         @[@"Камера",@(UIImagePickerControllerSourceTypeCamera)],
                         @[@"Фотоальбом",@(UIImagePickerControllerSourceTypePhotoLibrary)],
                         @[@"Сохраненные фотографии",@(UIImagePickerControllerSourceTypeSavedPhotosAlbum)],
                         ])
    {
        if ([i[1] integerValue] == UIImagePickerControllerSourceTypeCamera && self.albumsOnly) continue;
        if ([i[1] integerValue] != UIImagePickerControllerSourceTypeCamera && self.cameraOnly) continue;
        if (![UIImagePickerController isSourceTypeAvailable:[i[1] integerValue]]) continue;
        lastSource = [i[1] integerValue];
        UIAlertAction *action = [UIAlertAction actionWithTitle:i[0]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *a){
                                                           [self takePhotoWithSource:[i[1] integerValue]];
                                                       }];
        [photoPicker addAction:action];
    }
    
    if (photoPicker.actions.count == 1)
    {
        // only one source
        [self takePhotoWithSource:lastSource];
        return;
    }
    if (photoPicker.actions.count == 0)
    {
        // no sources
        self.callback(nil, nil, nil);
        return;
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Отменить"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *a){
                                                             self.callback(nil, nil, nil);
                                                         }];
    [photoPicker addAction:cancelAction];
    
    [self.controller presentViewController:photoPicker
                       animated:YES
                     completion:nil];
}


@end
