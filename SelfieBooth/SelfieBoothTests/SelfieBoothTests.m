//
//  SelfieBoothTests.m
//  SelfieBoothTests
//
//  Created by Rohan Aurora on 10/14/14.
//  Copyright (c) 2014 Rohan Aurora. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppDelegate.h"
#import "SelfieCollectionViewController.h"
#import "SelfieViewCell.h"

@interface SelfieBoothTests : XCTestCase
@property (nonatomic, strong) SelfieCollectionViewController *scv;
@property (nonatomic, strong) SelfieViewCell *selfieViewCell;
@property (nonatomic, weak) NSDictionary *_photo;
@end

@implementation SelfieBoothTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.scv = [SelfieCollectionViewController new];
    self.selfieViewCell = [SelfieViewCell new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.scv = nil;
    self.selfieViewCell = nil;
    __photo = nil;
}


-(void)testIfCollectionView {
    
    XCTAssertTrue([self.scv isKindOfClass:[UICollectionViewController class]], @"SelfieCollectionViewController should be a subclass of UICollectionView");
}

-(void)testIfViewControllerIsNil {
    
    XCTAssertNotNil([self.scv view], @"ViewController should contain a view");
}

-(void)setPhotoTestForNil {
    
    XCTAssertNotNil([self.selfieViewCell setPhoto:nil], @"Photo should be set");
    
}


@end
