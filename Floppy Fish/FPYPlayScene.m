//
//  FPYPlayScene.m
//  Floppy Fish
//
//  Created by Andrew Paterson on 1/29/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

#import "FPYPlayScene.h"
#import "SKBButtonNode.h"
#import "FPYMyScene.h"
#import "FPYScoreFormatter.h"
@import CoreGraphics;

@interface FPYPlayScene ()
@property (nonatomic, assign)BOOL started;
@property (nonatomic, assign)BOOL finished;
@property (nonatomic, assign)BOOL contentCreated;
@property (nonatomic, assign)BOOL touching;
@property (nonatomic, strong)SKSpriteNode *fish;
@property (nonatomic, assign)int score;
@property (strong, nonatomic)NSArray *leaderboards;
@property(nonatomic, retain) NSMutableDictionary *achievementsDictionary;
@property (nonatomic, assign)int bestScore;
@end

@implementation FPYPlayScene{
    float scaleFactor;
}
@synthesize achievementsDictionary;
#define PIPE @"Pipe_Coral_200x750REZ"
#define PIPEDOWN @"Pipe_Coral_Down_200x750REZ"
typedef NS_ENUM(NSInteger, FPYPipeDirection){
    FPYPipeDirectionUp,
    FPYPipeDirectionDown
};
static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}
static inline CGFloat skRand(CGFloat low, CGFloat high){
    return skRandf() *(high - low) + low;
}
static const uint32_t fishCategory = 0x1 << 0;
static const uint32_t pipeCategory = 0x1 << 1;
#pragma mark - Init
- (instancetype)initWithSize:(CGSize)size{
    self = [super initWithSize:size];
    if(self){
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            scaleFactor = 2.0;
        }
        else{
            scaleFactor = 1.0;
        }
        if (!self.contentCreated) {
            self.physicsWorld.gravity = CGVectorMake(0, 0);
            self.physicsWorld.contactDelegate = self;
            self.bestScore = [[[NSUserDefaults standardUserDefaults] objectForKey:@"bestScore"] integerValue];
            NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"bestScore"]);
            NSLog(@"%d", self.bestScore);
            [self createSceneContent];
            self.contentCreated = YES;
        }

        dispatch_async(dispatch_queue_create("com.andrewpaterson.backgroundasync", NULL), ^{
            [FPYScoreFormatter sharedFormatter];
            NSLog(@"Loaded formatter async");
            [self loadAchievements];
            [self loadLeaderboardInfo];

        });
    }
    return self;
}
#pragma mark - Update
- (void)update:(NSTimeInterval)currentTime{
    if (self.started && self.touching) {
        if (self.fish.position.y > (100 * scaleFactor)) {
        self.fish.position = CGPointMake(self.fish.position.x, self.fish.position.y - (3 * scaleFactor));
        }
    }
    else if(self.started && !self.touching) {
        if (self.fish.position.y < CGRectGetMaxY(self.frame) - 30 * scaleFactor) {
        self.fish.position = CGPointMake(self.fish.position.x, self.fish.position.y + (3 * scaleFactor));
        }
    }
    if (self.started) {
        [self enumerateChildNodesWithName:@"pipeUp" usingBlock:^(SKNode *node, BOOL *stop) {
                //TODO: fill in block
            if ((self.started) && ((node.position.x > self.fish.position.x - 2) && (node.position.x < self.fish.position.x + 2))){
                self.score += 1;
                            }
            if (node.position.x < - 100) {
                [node removeFromParent];

            }
            else{
                node.position = CGPointMake(node.position.x - 3, node.position.y);

            }
        }];
        [self enumerateChildNodesWithName:@"pipeDown" usingBlock:^(SKNode *node, BOOL *stop) {
                //TODO: fill in block
            if (node.position.x < - 100) {
                [node removeFromParent];

            }
            else{
                node.position = CGPointMake(node.position.x - 3, node.position.y);
            }
        }];

    }
}
#pragma mark - Create Content
- (void)createSceneContent{
    [self addChild:[self backgroundNode]];
    [self addChild:[self newFish]];
    [self addChild:[self newStone]];
}
#pragma mark - Nodes
- (SKSpriteNode *)backgroundNode{
    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
    bg.anchorPoint = CGPointZero;
    return bg;
}
- (SKSpriteNode *)newFish{
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"fish"];
    sprite.position = CGPointMake(CGRectGetMidX(self.frame) - (30 * scaleFactor), CGRectGetMidY(self.frame));
    sprite.name = @"fish";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        CGFloat offsetX = sprite.frame.size.width * sprite.anchorPoint.x;
        CGFloat offsetY = sprite.frame.size.height * sprite.anchorPoint.y;

        CGMutablePathRef path = CGPathCreateMutable();

        CGPathMoveToPoint(path, NULL, 5 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, NULL, 17 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, NULL, 38 - offsetX, 11 - offsetY);
        CGPathAddLineToPoint(path, NULL, 38 - offsetX, 16 - offsetY);
        CGPathAddLineToPoint(path, NULL, 23 - offsetX, 27 - offsetY);
        CGPathAddLineToPoint(path, NULL, 7 - offsetX, 27 - offsetY);
        CGPathAddLineToPoint(path, NULL, 5 - offsetX, 24 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 24 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 18 - offsetY);
        CGPathAddLineToPoint(path, NULL, 2 - offsetX, 15 - offsetY);
        CGPathAddLineToPoint(path, NULL, 2 - offsetX, 4 - offsetY);
        
        CGPathCloseSubpath(path);
        
        sprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    }
    else{
        CGFloat offsetX = sprite.frame.size.width * sprite.anchorPoint.x;
        CGFloat offsetY = sprite.frame.size.height * sprite.anchorPoint.y;

        CGMutablePathRef path = CGPathCreateMutable();

        CGPathMoveToPoint(path, NULL, 12 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, NULL, 42 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, NULL, 68 - offsetX, 9 - offsetY);
        CGPathAddLineToPoint(path, NULL, 93 - offsetX, 27 - offsetY);
        CGPathAddLineToPoint(path, NULL, 93 - offsetX, 40 - offsetY);
        CGPathAddLineToPoint(path, NULL, 81 - offsetX, 53 - offsetY);
        CGPathAddLineToPoint(path, NULL, 56 - offsetX, 66 - offsetY);
        CGPathAddLineToPoint(path, NULL, 18 - offsetX, 66 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 58 - offsetY);
        CGPathAddLineToPoint(path, NULL, 0 - offsetX, 44 - offsetY);
        CGPathAddLineToPoint(path, NULL, 6 - offsetX, 17 - offsetY);
        
        CGPathCloseSubpath(path);
        
        sprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
            //Generated at http://dazchong.com/spritekit/
    }
    sprite.physicsBody.categoryBitMask = fishCategory;
    sprite.physicsBody.contactTestBitMask = pipeCategory;
    sprite.physicsBody.dynamic = YES;
    sprite.physicsBody.collisionBitMask = pipeCategory;
    self.fish = sprite;
    sprite.physicsBody.usesPreciseCollisionDetection = TRUE;
    sprite.zPosition = 25;
    return sprite;
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
#pragma mark - Pipe Making
- (SKSpriteNode *)newPipeWithDirection:(FPYPipeDirection)dirction{
    if(dirction == FPYPipeDirectionUp){
        SKSpriteNode *pipe = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[self imageWithImage:[UIImage imageNamed:PIPE] convertToSize:CGSizeMake(60 * scaleFactor, 375 * scaleFactor)]]];
        pipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe.size];
        pipe.physicsBody.categoryBitMask = pipeCategory;
        pipe.physicsBody.contactTestBitMask = fishCategory;
        pipe.physicsBody.collisionBitMask = fishCategory;
        pipe.physicsBody.dynamic = NO;
        pipe.physicsBody.usesPreciseCollisionDetection = TRUE;

        pipe.name = @"pipeUp";
        return pipe;
        
    }
    else if (dirction == FPYPipeDirectionDown){
        SKSpriteNode *pipe = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[self imageWithImage:[UIImage imageNamed:PIPEDOWN] convertToSize:CGSizeMake(60 * scaleFactor, 375 * scaleFactor)]]];
        pipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe.size];
        pipe.name = @"pipeDown";
        pipe.physicsBody.categoryBitMask = pipeCategory;
        pipe.physicsBody.contactTestBitMask = fishCategory;
        pipe.physicsBody.collisionBitMask = fishCategory;
        pipe.physicsBody.usesPreciseCollisionDetection = TRUE;
        pipe.physicsBody.dynamic = NO;
        return pipe;
    }
    else{
                NSLog(@"Invalid Pipe Direction");
        NSLog(@"Program Exited With Exit Code: 1");
        exit(1);
        return nil;

    }
}
#pragma mark - Start
- (void)start{
    if (self.started && !self.finished) {
        CGFloat low = CGRectGetMaxY(self.frame) - (50 * scaleFactor);
        CGFloat high = CGRectGetMaxY(self.frame) - (-75 * scaleFactor);
        SKSpriteNode *pipeUp = [self newPipeWithDirection:FPYPipeDirectionDown];
        pipeUp.position = CGPointMake(CGRectGetMaxX(self.frame) + 100, skRand(low, high));
        [self addChild:pipeUp];
        SKSpriteNode * pipeDown = [self newPipeWithDirection:FPYPipeDirectionUp];
        pipeDown.position = CGPointMake(CGRectGetMaxX(self.frame) + 100, (pipeUp.position.y - (100 * scaleFactor)) - pipeDown.size.height);
        [self addChild:pipeDown];

        [self performSelector:@selector(start) withObject:self afterDelay:1.0];
    }
}
#pragma mark - Die
- (void)die{
    if (self.score > self.bestScore) {
        self.bestScore = self.score;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.score] forKey:@"bestScore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"bestScore"]);

    }
    self.fish.physicsBody = nil;
    SKAction *moveToTop = [SKAction moveToY:CGRectGetMaxY(self.frame) -(30 * scaleFactor) duration:1.5];
    [self.fish runAction:moveToTop completion:^{
        self.fish.yScale = -1.0;
        [self presentScore];
        [self addChild:[self newRetryButton]];
        [self addChild:[self newMenuButton]];
    }];
    [self reportScore:self.score forLeaderboardID:@"High_Score"];
    if (self.score > 99) {
        [self reportAchievementIdentifier:@"Atlantian_Civilization" percentCompleteIncrease:100.0];
    }
    if (self.score > 39) {
        [self reportAchievementIdentifier:@"Mother_of_All_Pearls" percentCompleteIncrease:100.0];
    }
    if (self.score > 29) {
        [self reportAchievementIdentifier:@"Gold_Doubloon" percentCompleteIncrease:100.0];
    }
    if (self.score > 19) {
        [self reportAchievementIdentifier:@"Silver_Captains_Spoon" percentCompleteIncrease:100.0];
    }
    if (self.score > 9) {
        [self reportAchievementIdentifier:@"Bronze_Ship_Plate" percentCompleteIncrease:100.0];
    }
}
- (SKBButtonNode *)newRetryButton{
    UIImage *a = [UIImage imageNamed:@"RetryButton_Coral_300x110REZ"];
    SKTexture *tx = [SKTexture textureWithImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]];
    SKTexture *tx2 = [SKTexture textureWithImage:[self darkenImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]]];
    SKBButtonNode *play = [[SKBButtonNode alloc] initWithTextureNormal:tx selected:tx2];
    play.position = CGPointMake((75 * scaleFactor), (120 * scaleFactor));
    [play setTouchUpInsideTarget:self action:@selector(retry)];
    return play;

}
- (SKSpriteNode *)newStone{
    SKSpriteNode *stone = [SKSpriteNode spriteNodeWithImageNamed:@"Stone"];
    stone.anchorPoint = CGPointZero;
    stone.zPosition = 15;
    return stone;
}
- (SKBButtonNode *)newMenuButton{
    UIImage *a = [UIImage imageNamed:@"MenuButton_Coral_300x110REZ"];
    SKTexture *tx = [SKTexture textureWithImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]];
    SKTexture *tx2 = [SKTexture textureWithImage:[self darkenImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]]];
    SKBButtonNode *play = [[SKBButtonNode alloc] initWithTextureNormal:tx selected:tx2];
    play.position = CGPointMake((CGRectGetMaxX(self.frame) - (75 * scaleFactor)), (120 * scaleFactor));
    [play setTouchUpInsideTarget:self action:@selector(menu)];
    return play;
}
- (void)retry{
    FPYPlayScene *scene = [[FPYPlayScene alloc] initWithSize:self.size];
    SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionUp duration:0.5];
    [self.view presentScene:scene transition:transition];
}
- (void)menu{
    FPYMyScene *scene = [[FPYMyScene alloc] initWithSize:self.size];
    SKTransition *transition = [SKTransition moveInWithDirection:SKTransitionDirectionLeft duration:0.5];
    [self.view presentScene:scene transition:transition];
}
- (void)presentScore{
    SKSpriteNode *temp = [[FPYScoreFormatter sharedFormatter] scoreNumbersForScore:self.score highScore:self.bestScore ScaleFactor:scaleFactor];
    temp.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:temp];
        //TODO: add buttons
}
#pragma mark - Touch Handling
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if (!self.started && !self.finished) {
        self.started = YES;
        [self start];
        self.touching = YES;
    }
    else if (self.finished){
        self.touching = NO;
    }
    else{
        self.touching = YES;
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    if (self.touching) {
        self.touching = NO;
    }
}
#pragma mark - Collision Handling
- (void)didBeginContact:(SKPhysicsContact *)contact{
    [self die];
    self.started = NO;
    self.finished = YES;
}
#pragma mark - Game Center
- (void)loadLeaderboardInfo{
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error){
        self.leaderboards = leaderboards;
    }];
}
- (void)reportScore:(int64_t)score forLeaderboardID:(NSString *)category{
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:category];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    [GKScore reportScores:@[scoreReporter] withCompletionHandler:NULL];
}
- (void)loadAchievements{
    achievementsDictionary = [[NSMutableDictionary alloc] init];
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
     {
         if (error == nil)
         {
             for (GKAchievement* achievement in achievements)
                 [achievementsDictionary setObject: achievement forKey: achievement.identifier];
         }
     }];
}
- (void)reportAchievementIdentifier: (NSString*) identifier percentCompleteIncrease: (float) percent{
    GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
    if (achievement && achievement.percentComplete != 100.0)
    {
        achievement.percentComplete += percent;
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
        }];
    }
}
- (GKAchievement*) getAchievementForIdentifier: (NSString*) identifier{
    GKAchievement *achievement = [achievementsDictionary objectForKey:identifier];
    if (achievement == nil)
    {
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        [achievementsDictionary setObject:achievement forKey:achievement.identifier];
    }
    return achievement;
}
@end























