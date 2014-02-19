//
//  FPYAppDelegate.h
//  Floppy Fish
//
//  Created by Andrew Paterson on 1/29/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FPYAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property BOOL gameCenterEnabled;
typedef NS_ENUM(NSInteger, FPYFishColor){
    FPYFishColorDefault = 1,
    FPYFishColorRed = 2,
    FPYFishColorGreen = 3,
    FPYFishColorPurple = 4,
    FPYFishColorPink = 5,
    FPYFishColorBlue = 6
};
@property (assign, nonatomic)FPYFishColor fishColor;
@end
