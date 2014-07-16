//
//  RootViewController.m
//  Snapcat
//
//  Created by Ritu Vincent on 7/14/14.
//  Copyright (c) 2014 Ritu Vincent. All rights reserved.
//

#import "RootViewController.h"
#import "SCTableViewCell.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) refreshAll {
    // Clear state
    self.lastSticker = nil;
    self.sendTextButton.enabled = NO;
    for (UIView *subview in self.canvas.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }
}

- (void)cameraButtonClick:(UIButton *)sender {
    // Show image picker
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)catButtonClick:(UIButton *) sender {
    // Save selected cat sticker
    self.lastSticker = sender.imageView.image;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    // Place a cat sticker at tap location
    CGPoint location = [recognizer locationInView:self.picture];
    int x = location.x;
    int y = location.y;
    
    UIImageView *tempSticker = [[UIImageView alloc] initWithFrame:CGRectMake(x - 40, y - 40, 80, 80)];
    tempSticker.userInteractionEnabled = YES;
    tempSticker.image = self.lastSticker;
    
    // Add a bunch of gesture recognizers to remove, resize, rotate and drag the sticker
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteSticker:)];
    [tempSticker addGestureRecognizer:longTap];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(resizeSticker:)];
    [tempSticker addGestureRecognizer:pinch];
    
    UIRotationGestureRecognizer* rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateSticker:)];
    [tempSticker addGestureRecognizer:rotate];
    
    UIPanGestureRecognizer* move = [[UIPanGestureRecognizer alloc]  initWithTarget:self action:@selector(moveSticker:)];
    [tempSticker addGestureRecognizer:move];

    // Add sticker to canvas and play a sound
    [self.canvas addSubview:tempSticker];
    [self playSound];
    
    // Make sure z-ordering is correct
    [self.view bringSubviewToFront:self.takePictureButton];
    [self.view bringSubviewToFront:self.sendTextButton];
}

- (void)resizeSticker:(UIPinchGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

- (void)rotateSticker:(UIRotationGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
}

- (void)moveSticker:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)deleteSticker:(UILongPressGestureRecognizer *) recognizer {
    [recognizer.view removeFromSuperview];
}

- (void)playSound {
    SystemSoundID soundID;
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"meow" ofType:@"mp3"];
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:soundPath];
    
    AudioServicesCreateSystemSoundID (url, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

- (UIImage *)makeFinalImage {
    // Composite base image and all stickers into one image
    UIGraphicsBeginImageContext(self.canvas.frame.size);
    
    for (UIView* subview in self.canvas.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            // Draw image
            [((UIImageView *)subview).image drawInRect:subview.frame];
        }
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect bounds = self.view.bounds;
    self.canvas = [[UIView alloc] init];
    [self.canvas setFrame:CGRectMake(0, 0, bounds.size.width, 448)];
    [self.view addSubview:self.canvas];
    
    // Add button to launch image picker
    self.takePictureButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.takePictureButton setFrame:CGRectMake(0, 448, bounds.size.width/2, 40)];
    [self.takePictureButton setTitle:@"Take a picture" forState:UIControlStateNormal];
    [self.view addSubview:self.takePictureButton];
    [self.takePictureButton addTarget:self action: @selector(cameraButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.takePictureButton.layer.borderWidth = 1.0f;
    self.takePictureButton.backgroundColor = [UIColor whiteColor];
    self.takePictureButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.takePictureButton.layer.cornerRadius = 4.0f;
    
    // Add button to launch message composer
    self.sendTextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendTextButton setFrame:CGRectMake(bounds.size.width/2, 448, bounds.size.width/2, 40)];
    [self.sendTextButton setTitle:@"Text picture" forState:UIControlStateNormal];
    [self.view addSubview:self.sendTextButton];
    [self.sendTextButton addTarget:self action: @selector(sendText:) forControlEvents:UIControlEventTouchUpInside];
    self.sendTextButton.layer.borderWidth = 1.0f;
    self.sendTextButton.backgroundColor = [UIColor whiteColor];
    self.sendTextButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.sendTextButton.layer.cornerRadius = 4.0f;
    self.sendTextButton.enabled = NO; // Disable until there's something to send
    
    // Add all stickers
    UIScrollView* catTable = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 488, bounds.size.width, 80)];
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

- (void)sendText:(UIButton *)sender {
    // Create text message compose controller
    MFMessageComposeViewController* msgComposer = [[MFMessageComposeViewController alloc] init];

    // Attach image data to message if we can
    if([MFMessageComposeViewController canSendText])
    {
        if([MFMessageComposeViewController respondsToSelector:@selector(canSendAttachments)] && [MFMessageComposeViewController canSendAttachments])
        {
            msgComposer.messageComposeDelegate = self;
            msgComposer.recipients = [NSArray arrayWithObjects: nil];

            NSData* imageData = UIImageJPEGRepresentation([self makeFinalImage], 1.0);
            NSString* uti = (NSString*)kUTTypeMessage;
            [msgComposer addAttachmentData:imageData typeIdentifier:uti filename:@"kitty.jpg"];
        }
        
        [self presentViewController:msgComposer animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get selected image
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    // Create view for chosen image and add to canvas
    self.picture = [[UIImageView alloc] initWithFrame:self.canvas.frame];
    self.picture.image = chosenImage;
    self.picture.userInteractionEnabled = YES;
    [self.canvas addSubview:self.picture];
    
    // Add a tap gesture recognizer
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.picture addGestureRecognizer:singleFingerTap];

    // Close image picker
    [self.imagePicker dismissViewControllerAnimated:NO completion:nil];
    
    // Enable text button
    self.sendTextButton.enabled = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:NO completion:nil];
}

@end
