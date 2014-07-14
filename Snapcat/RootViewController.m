//
//  RootViewController.m
//  Snapcat
//
//  Created by Ritu Vincent on 7/14/14.
//  Copyright (c) 2014 Ritu Vincent. All rights reserved.
//

#import "RootViewController.h"
#import "SCTableViewCell.h"

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
    self.sticker = sender.imageView.image;
}

- (void) handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.imageView];
    int x = location.x;
    int y = location.y;
    
    UIImage *baseImage = self.imageView.image;
    CGSize baseSize = self.imageView.frame.size;
    CGSize stickerSize = self.sticker.size;
    
    UIGraphicsBeginImageContext(baseSize);
    
    // Draw background
    [baseImage drawInRect:CGRectMake(0, 0, baseSize.width, baseSize.height)];
    
    // Draw sticker
    [self.sticker drawInRect:CGRectMake(x - 40, y - 40, 80, 80)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    self.imageView.image = newImage;
    
    UIGraphicsEndImageContext();
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect bounds = self.view.bounds;
    self.imageView = [[UIImageView alloc] init];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView setFrame:CGRectMake(0, 0, bounds.size.width, 400)];
    [self.view addSubview:self.imageView];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.imageView addGestureRecognizer:singleFingerTap];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(0, 400, bounds.size.width, 20)];
    [button setTitle:@"Choose a picture" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action: @selector(cameraButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Image selected");
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    self.imageView.image = chosenImage;
    
    [self.picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.picker dismissViewControllerAnimated:NO completion:nil];
    
}

@end
