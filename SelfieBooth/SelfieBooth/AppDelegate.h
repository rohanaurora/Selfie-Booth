//
//  AppDelegate.h
//  SelfieBooth
//
//  Created by Rohan Aurora on 10/14/14.
//  Copyright (c) 2014 Rohan Aurora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetCheck.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, NetCheckDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
