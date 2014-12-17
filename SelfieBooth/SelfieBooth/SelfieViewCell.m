//
//  SelfieViewCell.m
//  SelfieBooth
//
//  Created by Rohan Aurora on 10/14/14.
//  Copyright (c) 2014 Rohan Aurora. All rights reserved.
//

#import "SelfieViewCell.h"
#import "SelfieCollectionViewController.h"
#import "SelfieModel.h"

@implementation SelfieViewCell

#pragma mark
#pragma mark - Set photo in cells
#pragma mark

-(void) setPhoto:(NSDictionary *)photo {
    _photo = photo;
    
    // Class method
    [SelfieModel imageForPhoto:_photo size:@"thumbnail" completion:^(UIImage *image) {
        
        self.imageView.image = image;
    }];
}

#pragma mark
#pragma mark - Long press gesture recognition
#pragma mark

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(likeSelfie)];
        longPress.minimumPressDuration = 1.0f;
        [self addGestureRecognizer:longPress];
        
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

#pragma mark
#pragma mark - Photo Cell Layout
#pragma mark

-(void) layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = self.contentView.bounds;
}

#pragma mark
#pragma mark - Instagram Like Network Call
#pragma mark

-(void) likeSelfie {
    
    NSURLSession *session = [NSURLSession sharedSession];

    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.instagram.com/v1/media/%@/likes?access_token=%@", self.photo[@"id"],accessToken ];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showLikedCompletion];
        });
    }];
    
    [task resume];
}

#pragma mark
#pragma mark - Instagram Like
#pragma mark

-(void) showLikedCompletion {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Liked!" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
    [alert show];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
}


@end
