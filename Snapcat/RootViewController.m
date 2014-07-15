//
//  RootViewController.m
//  Snapcat
//
//  Created by Ritu Vincent on 7/14/14.
//  Copyright (c) 2014 Ritu Vincent. All rights reserved.
//

#import "RootViewController.h"
#import "SCTableViewCell.h"
#import "SCStickerInfo.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface RootViewController ()

@end

@implementation RootViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)cameraButtonClick:(UIButton *)sender
{
    
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    self.picker.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self presentViewController:self.picker animated:YES completion:NULL];
}

- (void) catButtonClick:(UIButton *) sender
{
    self.lastSticker = sender.imageView.image;
}

- (void) handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.picture];
    int x = location.x;
    int y = location.y;
    
    //UIImage *baseImage = self.picture.image;
    //CGSize baseSize = self.picture.frame.size;
    //CGSize stickerSize = self.sticker.size;
    
    UIImageView *tempSticker = [[UIImageView alloc] initWithFrame:CGRectMake(x - 40, y - 40, 80, 80)];
    tempSticker.userInteractionEnabled = YES;
    tempSticker.image = self.lastSticker;
    
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteSticker:)];
    [tempSticker addGestureRecognizer:longTap];

    [self.canvas addSubview:tempSticker];
    [self playSound];

}

- (void) deleteSticker:(UILongPressGestureRecognizer *) recognizer {
    UIView* sticker = recognizer.view;
    [sticker removeFromSuperview];
}

- (void) playSound{
    SystemSoundID soundID;
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"meow" ofType:@"mp3"];
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:soundPath];
    
    AudioServicesCreateSystemSoundID (url, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

- (UIImage *) makeFinalImage {
    UIGraphicsBeginImageContext(self.canvas.frame.size);
    
    for (UIView* subView in self.canvas.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            // Draw image
            [((UIImageView *)subView).image drawInRect:subView.frame];
        }
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect bounds = self.view.bounds;
    self.canvas = [[UIView alloc] init];
    [self.canvas setFrame:CGRectMake(0, 0, bounds.size.width, 400)];
    [self.view addSubview:self.canvas];
    
    
    /*self.imageView = [[UIView alloc] init];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView setFrame:CGRectMake(0, 0, bounds.size.width, 400)];
    [self.view addSubview:self.imageView];*/
    
    //UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    //[self.imageView addGestureRecognizer:singleFingerTap];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(0, 400, bounds.size.width/2, 20)];
    [button setTitle:@"Choose a picture" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action: @selector(cameraButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* sendText = [UIButton buttonWithType:UIButtonTypeSystem];
    [sendText setFrame:CGRectMake(bounds.size.width/2, 400, bounds.size.width/2, 20)];
    [sendText setTitle:@"Text picture" forState:UIControlStateNormal];
    [self.view addSubview:sendText];
    [sendText addTarget:self action: @selector(sendText:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIScrollView* catTable = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 420, bounds.size.width, 80)];
    for (int i = 0; i < 10; i++) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(i * 80, 0, 80, 80)];
        
        NSString* imageName = [[NSBundle mainBundle] pathForResource:@"snapcat2" ofType:@"gif"];
        UIImage* imageObj = [[UIImage alloc] initWithContentsOfFile:imageName];
        [button setImage:imageObj forState:UIControlStateNormal];
        [button addTarget:self action: @selector(catButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [catTable addSubview:button];
    }
    
    catTable.contentSize=CGSizeMake(80 * 10, 80);
    [self.view addSubview:catTable];
}

- (void)sendText:(UIButton *)sender{
    NSLog(@"Send Text");
    MFMessageComposeViewController* sendText = [[MFMessageComposeViewController alloc] init];
    sendText.messageComposeDelegate = self;
    sendText.recipients = [NSArray arrayWithObjects: nil];
    
    NSData* imageData = UIImageJPEGRepresentation([self makeFinalImage], 1.0);
    if([MFMessageComposeViewController canSendText])
    {
        if([MFMessageComposeViewController respondsToSelector:@selector(canSendAttachments)] && [MFMessageComposeViewController canSendAttachments])
        {
            NSString* uti = (NSString*)kUTTypeMessage;
            [sendText addAttachmentData:imageData typeIdentifier:uti filename:@"kitty.jpg"];
        }
        
        [self presentViewController:sendText animated:YES completion:nil];
    }
}

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Image selected");
    
    self.picture = [[UIImageView alloc] initWithFrame:self.canvas.frame];
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    self.picture.image = chosenImage;
    self.picture.userInteractionEnabled = YES;
    [self.canvas addSubview:self.picture];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.picture addGestureRecognizer:singleFingerTap];

    
    [self.picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.picker dismissViewControllerAnimated:NO completion:nil];
    
}

@end
