//
//  FPYAppDelegate.m
//  Floppy Fish
//
//  Created by Andrew Paterson on 1/29/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

#import "FPYAppDelegate.h"
#import "FPYScoreFormatter.h"
#import <Crashlytics/Crashlytics.h>


@implementation FPYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Crashlytics startWithAPIKey:@"1c6d125161cfd6155af441bc83d21a64632d815c"];
        // Initialize tracker.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"fishColor"]) {
        NSString *color = [[NSUserDefaults standardUserDefaults] objectForKey:@"fishColor"];
        if ([color isEqualToString:@"default"]) {
            self.fishColor = FPYFishColorDefault;
        }
        else if ([color isEqualToString:@"red"]){
            self.fishColor = FPYFishColorBlue;
        }
        else if ([color isEqualToString:@"blue"]){
            self.fishColor = FPYFishColorBlue;
        }
        else if ([color isEqualToString:@"green"]){
            self.fishColor = FPYFishColorGreen;
        }
        else if ([color isEqualToString:@"pink"]){
            self.fishColor = FPYFishColorPink;
        }
        else if ([color isEqualToString:@"purple"]){
            self.fishColor = FPYFishColorPurple;
        }
    }
    else{
        self.fishColor = FPYFishColorDefault;
        [[NSUserDefaults standardUserDefaults] setObject:@"default" forKey:@"fishColor"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    [[FPYScoreFormatter sharedFormatter] dumpCore];
}
@end
