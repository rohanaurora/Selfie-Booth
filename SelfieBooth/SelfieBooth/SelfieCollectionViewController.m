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

@interface SelfieCollectionViewController ()

@end

@implementation SelfieCollectionViewController

#pragma mark - Initialization

-(instancetype) init {
    
    // Layout for collection view
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(106.0, 106.0);
    layout.minimumInteritemSpacing = 1.0;
    layout.minimumLineSpacing = 1.0;
    
    return (self = [super initWithCollectionViewLayout:layout]);
}


#pragma mark - Access Token

-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Selfie Booth (Audible Inc.) ";
    
    // Register class for cells.
    [self.collectionView registerClass:[SelfieViewCell class] forCellWithReuseIdentifier:@"photo"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    
    // Saving access token on disk. Will use Keychain if time permits.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.accessToken = [userDefaults objectForKey:@"accessToken"];
    
    
    // No access token: Create one and store.
    if (self.accessToken == nil) {
        
        [SimpleAuth authorize:@"instagram" options:@{@"scope":@[@"likes"]} completion:^(NSDictionary *responseObject, NSError *error) {
            
            self.accessToken = [[responseObject objectForKey:@"credentials"] objectForKey:@"token"];
            
            [userDefaults setObject:self.accessToken forKey:@"accessToken"];
            [userDefaults synchronize];
            [self refresh];
        }];
    } else {
        
        // Get max_tag_id and then get media. Start OperationQueue.
        NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
        [opQueue setMaxConcurrentOperationCount:5];
        
        // Parallel task to get max_tag_id
        [opQueue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getMoreData) object:nil]];
        
        [opQueue waitUntilAllOperationsAreFinished];
        
        // max_tag_id is ready to use, queue is run faster parallely.
        [self refresh];
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
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *photo = self.photos[indexPath.row];
    
    DetailsViewController *dvc = [[DetailsViewController alloc] init];
    dvc.photo = photo;
    
    [self presentViewController:dvc animated:YES completion:nil];
}



#pragma mark - First Network Call

// Updates max_tag_id - parameter required get more images (greater than 20).
- (NSDictionary *) getMoreData {
    
    {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSDictionary *getIDDictionary = nil;
        
        NSURLSessionConfiguration *sessionConfigForDeal = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSString *myString = [NSString stringWithFormat:@"https://api.instagram.com/v1/tags/selfie/media/recent?access_token=%@", self.accessToken];
        NSURL * url = [NSURL URLWithString:myString];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        [[[NSURLSession sessionWithConfiguration:sessionConfigForDeal] downloadTaskWithRequest:request completionHandler:^(NSURL *taskLocation, NSURLResponse *taskResponse, NSError *taskError) {
            
            NSData *newData = [[NSData alloc] initWithContentsOfURL:taskLocation];
            NSDictionary *paginationResponse = [NSJSONSerialization JSONObjectWithData:newData options:kNilOptions error:nil];
            
            getIDDictionary = [[paginationResponse objectForKey:@"pagination"] objectForKey:@"next_max_tag_id"];
            NSLog(@"Updated max_id is %@",getIDDictionary);
            
            // Error response if anything fails
            if (getIDDictionary == NULL) {
                NSLog(@"%@",paginationResponse);
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
-(void) refresh {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Trying to access more than 20 images. Pulled a request on Github - https://github.com/Instagram/instagram-ruby-gem/issues/140
    // Currently, able to fetch 33 images with a &count parameter to URL
    
    NSString *tagMediaURL = [NSString stringWithFormat:@"https://api.instagram.com/v1/tags/selfie/media/recent?access_token=%@&max_tag_id=%@&count=200", self.accessToken, self.max_id];
    
    NSLog(@"%@",tagMediaURL);
    
    NSURL *urlString = [NSURL URLWithString:tagMediaURL];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:urlString];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSData *myData = [[NSData alloc] initWithContentsOfURL:location];
        
        //  NSString *text = [NSString stringWithContentsOfURL:location encoding:NSUTF8StringEncoding error:nil];
        //  NSLog(@"Text - %@",text);
        
        NSDictionary *myJSON = [NSJSONSerialization JSONObjectWithData:myData options:kNilOptions error:nil];
        
        self.photos = [myJSON valueForKeyPath:@"data"];
        
        // Main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            
        });
    }];
    
    [task resume];
}



@end
