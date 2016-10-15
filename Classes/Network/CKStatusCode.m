//
//  CKStatusCode.m
//  click
//
//  Created by Дрягин Павел on 13.10.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKStatusCode.h"

#define kImageTypeArray @"JPEG", @"PNG", @"GIF", @"PowerVR", nil

@implementation CKStatusCode

// Place this in the .m file, inside the @implementation block
// A method to convert an enum to string
-(NSString*) imageTypeEnumToString:(CKStatusCode)enumVal
{
    NSArray *imageTypeArray = [[NSArray alloc] initWithObjects:kImageTypeArray];
    return [imageTypeArray objectAtIndex:enumVal];
}

// A method to retrieve the int value from the NSArray of NSStrings
-(CKStatusCode) imageTypeStringToEnum:(NSString*)strVal
{
    NSArray *imageTypeArray = [[NSArray alloc] initWithObjects:kImageTypeArray];
    NSUInteger n = [imageTypeArray indexOfObject:strVal];
    if(n < 1) n = JPG;
    return (kImageType) n;
}

@end
