//
//  FPYViewController.m
//  Floppy Fish
//
//  Created by Andrew Paterson on 1/29/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

#import "FPYViewController.h"
#import "FPYMyScene.h"
#import "FPYAppDelegate.h"
@import GameKit;
@interface FPYViewController ()
@property (strong, nonatomic)NSString *username;
@end

@implementation FPYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
        //skView.showsFPS = YES;
        //skView.showsNodeCount = YES;
        //skView.showsDrawCount = YES;
    [self authenticatedPlayer:nil];
    dispatch_async(dispatch_queue_create("com.andrewpaterson.gkauth", NULL), ^{
        [self authenticateLocalPlayer];
    });


    // Create and configure the scene.
    SKScene * scene = [FPYMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
- (void)disableGameCenter{
    FPYAppDelegate *ad = [[UIApplication sharedApplication] delegate];
    ad.gameCenterEnabled = NO;
}
- (void)authenticatedPlayer:(GKLocalPlayer *)localPlayer{
    _username = localPlayer.displayName;
}
- (void)authenticateLocalPlayer{
    dispatch_async(dispatch_queue_create("com.AndrewPaterson.SpacePlatypus.AuthenticateLocalPlayer", NULL), ^{
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
            if (viewController != Nil) {
                [self presentViewController:viewController animated:YES completion:NULL];
            }
            else if ([GKLocalPlayer localPlayer].isAuthenticated){
                [self authenticatedPlayer:[GKLocalPlayer localPlayer]];
            }
            else {
                [self disableGameCenter];
            }
        };
    });
    
}
- (BOOL)shouldAutorotate{
    return NO;
}
@end
