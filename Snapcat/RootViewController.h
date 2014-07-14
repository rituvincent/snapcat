//
//  RootViewController.h
//  Snapcat
//
//  Created by Ritu Vincent on 7/14/14.
//  Copyright (c) 2014 Ritu Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *sticker;

@end
