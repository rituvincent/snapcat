//
//  RootViewController.h
//  Snapcat
//
//  Created by Ritu Vincent on 7/14/14.
//  Copyright (c) 2014 Ritu Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface RootViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate>


@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) UIView *canvas;
@property (strong, nonatomic) UIImageView *picture;
@property (strong, nonatomic) UIImage *lastSticker;
@property (strong, nonatomic) MFMessageComposeViewController* sendText;


@end


