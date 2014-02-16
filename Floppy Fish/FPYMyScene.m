//
//  FPYMyScene.m
//  Floppy Fish
//
//  Created by Andrew Paterson on 1/29/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

#import "FPYMyScene.h"
#import "SKBButtonNode.h"
#import "FPYPlayScene.h"
#import "FPYScoreFormatter.h"
@import GameKit;


@interface FPYMyScene ()

@property BOOL contentCreated;
@property (strong, nonatomic)SKSpriteNode *bar;

@end


@implementation FPYMyScene{
    float scaleFactor;
}

#define FLOPPY_FISH_LABEL_IMAGE @"FloppyFishLabel"


#pragma mark - Initializer

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        scaleFactor = 1.0f;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            scaleFactor = 2.0f;
        }
        if (!self.contentCreated) {
            [self createSceneContent];
            self.contentCreated = YES;
        }
    }
    return self;
}


#pragma mark - Scene Touch Handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    [super touchesBegan:touches withEvent:event];
}


#pragma mark - Scene Update Methods
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (self.bar.position.x <= 0) {
        [self addAndAnimateBar];
    }
}


#pragma mark - Scene Content Creation Manager

- (void)createSceneContent{
    [self addChild:[self backgroundNode]];
    [self addChild:[self newFloppyFishLabelNode]];
        [self addChild:[self newPlayButton]];
    [self addChild:[self newFish]];
           [self addChild:[self newScoreButton]];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"bestScore"] integerValue] > 29) {
        [self addChild:[self newRateButton]];
    }
    [self addAndAnimateBar];
    NSMutableArray *arr = [[[NSUserDefaults standardUserDefaults] objectForKey:@"scores"] mutableCopy];
    float average = 0;
    float count = 0;
    for (NSNumber *num in arr) {
        count++;
        average += [num floatValue];
    }
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    label.fontSize = 26;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    label.position = CGPointMake(CGRectGetMaxX(self.frame), 30 * scaleFactor);
    average = average/count;
    label.text = [NSString stringWithFormat:@"Average: %0.2f", average];
    if ([label.text  isEqual: @"Average: nan"]) {
        label.text = @"Average: 0";
    }
    NSLog(@"%0.2f", average);
    [self addChild:label];
}


#pragma mark - Scene Content Creators

- (SKSpriteNode *)newFloppyFishLabelNode{
    SKSpriteNode *floppyLabelNode = [SKSpriteNode spriteNodeWithImageNamed:FLOPPY_FISH_LABEL_IMAGE];
    floppyLabelNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - (60 * scaleFactor));
    return floppyLabelNode;
}
- (SKSpriteNode *)backgroundNode{
    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
    bg.anchorPoint = CGPointZero;
    return bg;
}
- (SKBButtonNode *)newPlayButton{
    UIImage *a = [UIImage imageNamed:@"StartButton_Coral_300x110REZ"];
    SKTexture *tx = [SKTexture textureWithImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]];
    SKTexture *tx2 = [SKTexture textureWithImage:[self darkenImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]]];
    SKBButtonNode *play = [[SKBButtonNode alloc] initWithTextureNormal:tx selected:tx2];
    play.position = CGPointMake((75 * scaleFactor), (140 * scaleFactor));
    [play setTouchUpInsideTarget:self action:@selector(play)];
    return play;
}
- (SKBButtonNode *)newScoreButton{
    UIImage *a = [UIImage imageNamed:@"ScoresButton_Coral_300x110REZ"];
    SKTexture *tx = [SKTexture textureWithImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]];
    SKTexture *tx2 = [SKTexture textureWithImage:[self darkenImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]]];
    SKBButtonNode *play = [[SKBButtonNode alloc] initWithTextureNormal:tx selected:tx2];
    play.position = CGPointMake((CGRectGetMaxX(self.frame) - (75 * scaleFactor)), (140 * scaleFactor));
    [play setTouchUpInsideTarget:self action:@selector(scores)];
    return play;
}
- (SKBButtonNode *)newRateButton{
    UIImage *a = [UIImage imageNamed:@"RateButton_Coral_300x110REZ"];
    SKTexture *tx = [SKTexture textureWithImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]];
    SKTexture *tx2 = [SKTexture textureWithImage:[self darkenImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]]];
    SKBButtonNode *play = [[SKBButtonNode alloc] initWithTextureNormal:tx selected:tx2];
    play.position = CGPointMake((CGRectGetMaxX(self.frame) - (75 * scaleFactor)), (180 * scaleFactor));
    [play setTouchUpInsideTarget:self action:@selector(rate)];
    return play;
}
- (SKSpriteNode *)newFish{
    SKSpriteNode *fish = [SKSpriteNode spriteNodeWithImageNamed:@"fish"];
    fish.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    SKAction *changeImages = [SKAction animateWithTextures:@[[SKTexture textureWithImageNamed:@"fishTwo"] ,[SKTexture textureWithImageNamed:@"fish"]] timePerFrame:0.25];
    [fish runAction:[SKAction repeatActionForever:changeImages]];
    return fish;
}
- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return destImage;
        //return image;

}
- (UIImage *)darkenImage:(UIImage *)image{
    CIImage *ref = [CIImage imageWithCGImage:[image CGImage]];
    CIFilter *darken = [CIFilter filterWithName:@"CIPhotoEffectFade" keysAndValues:kCIInputImageKey, ref, nil];
        CIContext *context = [CIContext contextWithOptions:Nil];
    CIImage *outputImage = [darken outputImage];

        CGImageRef cgimg =
        [context createCGImage:outputImage fromRect:[outputImage extent]];
        UIImage *newImg = [UIImage imageWithCGImage:cgimg];
        //UIImage *newImg = [UIImage imageWithCIImage:outputImage];
        CGImageRelease(cgimg);
    return newImg;
}
- (void)addAndAnimateBar{
    if (self.bar) {
        UIImage *bar = [UIImage imageNamed:@"bar"];
        bar = [self imageWithImage:bar convertToSize:CGSizeMake(bar.size.width / (2/scaleFactor), 12.5 * scaleFactor)];
        SKSpriteNode *barNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:bar]];
        barNode.position = CGPointMake(bar.size.width - 5, 80 * scaleFactor);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            barNode.position = CGPointMake(bar.size.width -10, 100 * scaleFactor);
        }
        [self addChild:barNode];
        self.bar.zPosition = 30;
        self.bar = barNode;
        self.bar.name = @"bar";
        SKAction *move = [SKAction moveByX:-1.5 * scaleFactor y:0.0 duration:0.01];
        [self.bar runAction:[SKAction repeatActionForever:move]];
    }
    else{
        UIImage *bar = [UIImage imageNamed:@"bar"];
        bar = [self imageWithImage:bar convertToSize:CGSizeMake(bar.size.width / (2/scaleFactor), 12.5 * scaleFactor)];
        SKSpriteNode *barNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:bar]];
        barNode.position = CGPointMake(0 + (bar.size.width / 2), 80 * scaleFactor);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            barNode.position = CGPointMake(bar.size.width / 2, 100 * scaleFactor);
        }
        [self addChild:barNode];
        self.bar = barNode;
        self.bar.zPosition = 30;
        self.bar.name = @"bar";
        SKAction *move = [SKAction moveByX:-1.5 * scaleFactor y:0.0 duration:0.01];
        [self.bar runAction:[SKAction repeatActionForever:move]];
    }
}
#pragma mark - Menu Item Methods

- (void)play{
        // TODO: Play
    SKTransition *tr = [SKTransition moveInWithDirection:SKTransitionDirectionRight duration:0.5];
    FPYPlayScene *scene = [[FPYPlayScene alloc] initWithSize:self.size];
    [self.view presentScene:scene transition:tr];
}
- (void)scores{
    [self showLeaderboard:@"High_Score_Two"];
}
- (void)rate{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http:www.appstore.com/fishdash"]];
}


#pragma mark - Game Center

- (void) showLeaderboard: (NSString*) leaderboardID
{
    dispatch_async(dispatch_queue_create("com.AndrewPaterson.SpacePlatypus.GKViewController", NULL), ^{
        GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
        if (gameCenterController != nil)
        {
            gameCenterController.gameCenterDelegate = self;
            gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
            [self.view.window.rootViewController presentViewController: gameCenterController animated: YES completion:nil];
        }
    });

}

- (void) showAchievements: (NSString*) leaderboardID
{
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        gameCenterController.viewState = GKGameCenterViewControllerStateAchievements;
        [self.view.window.rootViewController presentViewController: gameCenterController animated: YES completion:nil];
    }
}
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Contact Delegate

- (void)didBeginContact:(SKPhysicsContact *)contact{
    
}
@end
