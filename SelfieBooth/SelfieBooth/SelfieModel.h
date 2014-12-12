//
//  SelfieController.h
//  SelfieBooth
//
//  Created by Rohan Aurora on 10/14/14.
//  Copyright (c) 2014 Rohan Aurora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelfieModel : NSObject

+ (void) imageForPhoto:(NSDictionary *)
            photo size:(NSString *)size
            completion:(void(^)(UIImage *image))completion;

@end
