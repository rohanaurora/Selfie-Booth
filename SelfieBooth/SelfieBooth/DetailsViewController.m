//
//  DetailsViewController.m
//  SelfieBooth
//
//  Created by Rohan Aurora on 10/14/14.
//  Copyright (c) 2014 Rohan Aurora. All rights reserved.
//

#import "DetailsViewController.h"
#import "SelfieController.h"

#define kFullImageWidth  320
#define kFullImageHeight 320

@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kFullImageWidth, kFullImageHeight)];
    NSAssert(self.imageView != nil, @"photos must not be nil");

    [self.view addSubview:self.imageView];
    
    // Class Method
    [SelfieController imageForPhoto:self.photo size:@"standard_resolution" completion:^(UIImage *image) {
        self.imageView.image = image;
    }];
    
    // Tap to close
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    [self.view addGestureRecognizer:tap];
}

// Image layout
-(void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];

    // View controller's view's size
    CGSize size = self.view.bounds.size;
    
    // Image view's size
    CGSize imageSize = CGSizeMake(size.width, size.width);
    
    // Image view's frame
    self.imageView.frame = CGRectMake(0.0, (size.height - imageSize.height) / 2.0, imageSize.width, imageSize.height);
}


// Dismiss view
-(void) close {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
