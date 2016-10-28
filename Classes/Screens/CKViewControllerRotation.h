//
//  CKViewControllerRotation.h
//  click
//
//  Created by Дрягин Павел on 28.10.16.
//  Copyright © 2016 Click. All rights reserved.
//

@protocol CKViewControllerRotation

 // Если необходимо заблокировать поворот контроллера то необходимо вернуть в контроллере NO
- (BOOL)canAutoRotate;

@end
