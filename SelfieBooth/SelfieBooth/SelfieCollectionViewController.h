//
//  SelfieCollectionViewController.h
//  SelfieBooth
//
//  Created by Rohan Aurora on 10/14/14.
//  Copyright (c) 2014 Rohan Aurora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelfieCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate>

/// A valid access token from Instagram.
@property (nonatomic, strong) NSString *accessToken;

/// To get media earlier than this max_id.
@property (nonatomic, strong) NSString *max_id;

/// Object for all photos in collection view.
@property (nonatomic, strong) NSArray *photos;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end
