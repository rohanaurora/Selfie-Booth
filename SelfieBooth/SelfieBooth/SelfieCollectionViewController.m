//
//  SelfieCollectionViewController.m
//  SelfieBooth
//
//  Created by Rohan Aurora on 10/14/14.
//  Copyright (c) 2014 Rohan Aurora. All rights reserved.
//

#import "SelfieCollectionViewController.h"
#import "SelfieViewCell.h"
#import <SimpleAuth/SimpleAuth.h>
#import "DetailsViewController.h"
#import "PresentTransition.h"
#import "DismissTransition.h"
#import "MBProgressHUD.h"
#import <SSKeychain/SSKeychain.h>
#import <SSKeychain/SSKeychainQuery.h>

static NSString * const kPasswordForService  = @"com.therohanaurora.SelfieBooth";
static NSString * const kSelfieBoothTitle    = @"Selfie Booth";
static NSString * const kMediaURL            = @"https://api.instagram.com/v1/tags/selfies/media/recent?access_token=%@&max_tag_id=%@&count=200";
static NSString * const kAccessTokenURL      = @"https://api.instagram.com/v1/tags/selfie/media/recent?access_token=%@";

const CGFloat kTileWidth                    = 106.0f;
const CGFloat ktileHeight                   = 106.0f;
const CGFloat kTileSpacing                  =   1.0f;

@interface SelfieCollectionViewController ()

/// A valid access token from Instagram.
@property (nonatomic, strong, readwrite) NSString *accessToken;

/// To get media earlier than this max_id.
@property (nonatomic, strong, readwrite) NSString *max_id;

/// Object for all photos in collection view.
@property (nonatomic, strong, readwrite) NSArray *photos;

/// Object for pull-to-refresh feature
@property (nonatomic, strong, readwrite) UIRefreshControl *refreshControl;

@end

@implementation SelfieCollectionViewController

#pragma mark - Initialization

-(instancetype) init {
    
    // Layout for collection view
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kTileWidth, ktileHeight);
    layout.minimumInteritemSpacing = kTileSpacing;
    layout.minimumLineSpacing = kTileSpacing;
    
    return (self = [super initWithCollectionViewLayout:layout]);
}


#pragma mark - Access Token

-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = kSelfieBoothTitle;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
    [self.refreshControl addTarget:self action:@selector(refershControlAction) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    // Register class for cells.
    [self.collectionView registerClass:[SelfieViewCell class] forCellWithReuseIdentifier:@"photo"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    
    // Saving access token using Keychain.
    NSString *password = [SSKeychain passwordForService:kPasswordForService account:@"user"];
    self.accessToken = password;
    
    // No access token: Create one and store.
    if (self.accessToken == nil) {
        
        [SimpleAuth authorize:@"instagram" options:@{@"scope":@[@"likes"]} completion:^(NSDictionary *responseObject, NSError *error) {
            
            self.accessToken = [[responseObject objectForKey:@"credentials"] objectForKey:@"token"];
            
            [SSKeychain setPassword:self.accessToken forService:kPasswordForService account:@"user"];
            DLog(@"Access token saved in Keychain: %@", self.accessToken);
            
            // Get max_tag_id and then get media. Start OperationQueue.
            NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
            [opQueue setMaxConcurrentOperationCount:5];
            
            // Parallel task to get max_tag_id
            [opQueue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getMoreData) object:nil]];
            
            [opQueue waitUntilAllOperationsAreFinished];
            [self downloadPhotos];
        }];
        
    } else {
        
        ALog(@"Retrieving access token from Keychain: %@", self.accessToken);
        
        // Get max_tag_id and then get media. Start OperationQueue.
        NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
        [opQueue setMaxConcurrentOperationCount:5];
        
        // Parallel task to get max_tag_id
        [opQueue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getMoreData) object:nil]];
        
        [opQueue waitUntilAllOperationsAreFinished];
        [self downloadPhotos];
    }
}


#pragma mark - UICollectionView Delegate

// Method from UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.photos.count;
}

// Asks the data source delegate for the cell that corresponds to the specified item in the collection view.
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SelfieViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photo" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.photo = self.photos[indexPath.row];
    return cell;
}


// Tells the delegate that the photo at the specified index path was selected.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSDictionary *photo = self.photos[indexPath.row];
        DetailsViewController *dvc = [[DetailsViewController alloc] init];
        dvc.modalPresentationStyle = UIModalPresentationCustom;
        dvc.transitioningDelegate = self;
        dvc.photo = photo;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:dvc animated:YES completion:nil];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        });
    });
    
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[PresentTransition alloc] init];
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[DismissTransition alloc] init];
}


#pragma mark - First Network Call

// Updates max_tag_id - parameter required get more images (greater than 20).
- (NSDictionary *) getMoreData {
    
    {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSDictionary *getIDDictionary = nil;
        
        NSURLSessionConfiguration *sessionConfigForDeal = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSString *myString = [NSString stringWithFormat:kAccessTokenURL, self.accessToken];
        NSURL * url = [NSURL URLWithString:myString];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        [[[NSURLSession sessionWithConfiguration:sessionConfigForDeal] downloadTaskWithRequest:request completionHandler:^(NSURL *taskLocation, NSURLResponse *taskResponse, NSError *taskError) {
            
            NSData *newData = [[NSData alloc] initWithContentsOfURL:taskLocation];
            NSDictionary *paginationResponse = [NSJSONSerialization JSONObjectWithData:newData options:kNilOptions error:nil];
            
            getIDDictionary = [[paginationResponse objectForKey:@"pagination"] objectForKey:@"next_max_tag_id"];
            DLog(@"Updated max_id is %@",getIDDictionary);
            
            // Error response if anything fails
            if (getIDDictionary == NULL) {
                DLog(@"%@",paginationResponse);
            }
            
            dispatch_semaphore_signal(semaphore);
            self.max_id = [NSString stringWithFormat:@"%@",getIDDictionary];
            
        }] resume];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        return getIDDictionary;
    }
}


#pragma mark - Second Network Call

// Access token and max_tag_id exists. Download images.
-(void) downloadPhotos {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Trying to access more than 20 images. Pulled a request on Github - https://github.com/Instagram/instagram-ruby-gem/issues/140
    // Currently, able to fetch 33 images with a &count parameter to URL
    
    NSString *tagMediaURL = [NSString stringWithFormat:kMediaURL, self.accessToken, self.max_id];
    
    DLog(@"URL to get media: %@",tagMediaURL);
    
    NSURL *urlString = [NSURL URLWithString:tagMediaURL];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:urlString];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSData *dataFromURL = [[NSData alloc] initWithContentsOfURL:location];
        
        //  NSString *text = [NSString stringWithContentsOfURL:location encoding:NSUTF8StringEncoding error:nil];
        //  DLog(@"Text - %@",text);
        
        NSDictionary *photosDictionary = [NSJSONSerialization JSONObjectWithData:dataFromURL options:kNilOptions error:nil];
        
        self.photos = [photosDictionary valueForKeyPath:@"data"];
        
        // Main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            
        });
    }];
    
    [task resume];
}

#pragma mark - Pull-to-refresh Control

-(void) refershControlAction {
    // Doing something on the main thread
    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
    [opQueue setMaxConcurrentOperationCount:5];
    
    // Parallel task to get max_tag_id
    [opQueue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getMoreData) object:nil]];
    
    [opQueue waitUntilAllOperationsAreFinished];
    [self downloadPhotos];
    [self.refreshControl endRefreshing];
}


@end
