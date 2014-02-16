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
@property (nonatomic, assign)SKSpriteNode *bar;
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
        self.fish.position = CGPointMake(self.fish.position.x, self.fish.position.y - (3.2 * scaleFactor));
        }
    }
    else if(self.started && !self.touching) {
        if (self.fish.position.y < CGRectGetMaxY(self.frame) - 30 * scaleFactor) {
        self.fish.position = CGPointMake(self.fish.position.x, self.fish.position.y + (3.2 * scaleFactor));
        }
    }
    if (self.started) {


        [self enumerateChildNodesWithName:@"pipeUp" usingBlock:^(SKNode *node, BOOL *stop) {
                //TODO: fill in block
            if ((self.started) && ((node.position.x > self.fish.position.x - (2 * scaleFactor) && (node.position.x < self.fish.position.x + (2 * scaleFactor))))){
                self.score += 1;
                NSLog(@"%d", self.score);
                if ([self childNodeWithName:@"score"]) {


                [self removeChildrenInArray:@[[self childNodeWithName:@"score"]]];
                SKSpriteNode *score = [[FPYScoreFormatter sharedFormatter] nodeForScore:self.score scaleFactor:scaleFactor];
                score.position = CGPointMake(CGRectGetMidX(self.frame) - (50 * scaleFactor), CGRectGetMaxY(self.frame) -(50 * scaleFactor));
                score.zPosition = 90;
                score.name = @"score";
                [self addChild:score];
                }
                else{

                    SKSpriteNode *score = [[FPYScoreFormatter sharedFormatter] nodeForScore:self.score scaleFactor:scaleFactor];
                    score.position = CGPointMake(CGRectGetMidX(self.frame) - (50 * scaleFactor), CGRectGetMaxY(self.frame) -(50 * scaleFactor));
                    score.name = @"score";
                    score.zPosition = 90;
                    [self addChild:score];
                }
                            }
            if (node.position.x < - 100) {
                [node removeFromParent];

            }
            else{
                node.position = CGPointMake(node.position.x - (3 * scaleFactor), node.position.y);

            }
        }];
        [self enumerateChildNodesWithName:@"pipeDown" usingBlock:^(SKNode *node, BOOL *stop) {
                //TODO: fill in block
            if (node.position.x < - 100) {
                [node removeFromParent];

            }
            else{
                node.position = CGPointMake(node.position.x - (3 * scaleFactor), node.position.y);
            }
        }];

    }
    if (!self.finished) {
        if (self.bar.position.x <= 0) {
            [self addAndAnimateBar];
            self.bar.zPosition = 30;
        }
    }
    if (self.finished) {
        [self.bar removeAllActions];
        [self enumerateChildNodesWithName:@"bar" usingBlock:^(SKNode *node, BOOL *stop) {
            [node removeAllActions];
        }];
    }
        //NSLog(@"%f", self.bar.zPosition);
}
#pragma mark - Create Content
- (void)createSceneContent{
    [self addChild:[self backgroundNode]];
    [self addChild:[self newFish]];
    [self addChild:[self newStone]];
    [self addAndAnimateBar];
    SKLabelNode *touch = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    touch.text = @"Touch to swim down";
    touch.fontSize = 16;
    touch.position = CGPointMake(self.fish.position.x + (40 * scaleFactor) + (touch.frame.size.width / 2), self.fish.position.y);
    touch.name = @"label";
    [self addChild:touch];
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
        CGPathRelease(path);
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
        CGPathRelease(path);

            //Generated at http://dazchong.com/spritekit/
    }
    sprite.physicsBody.categoryBitMask = fishCategory;
    sprite.physicsBody.contactTestBitMask = pipeCategory;
    sprite.physicsBody.dynamic = YES;
    sprite.physicsBody.collisionBitMask = pipeCategory;
    SKAction *changeImages = [SKAction animateWithTextures:@[[SKTexture textureWithImageNamed:@"fishTwo"] ,[SKTexture textureWithImageNamed:@"fish"]] timePerFrame:0.25];
    [sprite runAction:[SKAction repeatActionForever:changeImages]];
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
    if ([self childNodeWithName:@"label"]) {
        [self removeChildrenInArray:@[[self childNodeWithName:@"label"]]];
    }
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
    [self.fish removeAllActions];
    [self.fish runAction:moveToTop completion:^{
        self.fish.yScale = -1.0;
        [self presentScore];
        [self addChild:[self newRetryButton]];
        [self addChild:[self newMenuButton]];
    }];
    [self reportScore:self.score forLeaderboardID:@"High_Score_Two"];
    if (self.score > 99) {
        [self reportAchievementIdentifier:@"Atlantian_Civilization_Two" percentCompleteIncrease:100.0];
    }
    if (self.score > 49) {
        [self reportAchievementIdentifier:@"Mother_of_All_Pearls_Two" percentCompleteIncrease:100.0];
    }
    if (self.score > 29) {
        [self reportAchievementIdentifier:@"Gold_Doubloon_Two" percentCompleteIncrease:100.0];
    }
    if (self.score > 19) {
        [self reportAchievementIdentifier:@"Silver_Captains_Spoon_Two" percentCompleteIncrease:100.0];
    }
    if (self.score > 9) {
        [self reportAchievementIdentifier:@"Bronze_Ship_Plate_Two" percentCompleteIncrease:100.0];
    }
    NSMutableArray *arr = [[[NSUserDefaults standardUserDefaults] objectForKey:@"scores"] mutableCopy];
    if (arr) {
        [arr addObject:[NSNumber numberWithInteger:self.score]];
        [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"scores"];
    }
    else{
        arr = [[NSMutableArray alloc] initWithArray:@[[NSNumber numberWithInteger:self.score]]];
        [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"scores"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    for (NSNumber *num in arr) {
        NSLog(@"%@", num);
    }
}
- (SKBButtonNode *)newRetryButton{
    UIImage *a = [UIImage imageNamed:@"RetryButton_Coral_300x110REZ"];
    SKTexture *tx = [SKTexture textureWithImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]];
    SKTexture *tx2 = [SKTexture textureWithImage:[self darkenImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]]];
    SKBButtonNode *play = [[SKBButtonNode alloc] initWithTextureNormal:tx selected:tx2];
    play.position = CGPointMake((75 * scaleFactor), (130 * scaleFactor));
    [play setTouchUpInsideTarget:self action:@selector(retry)];
    return play;

}
- (SKSpriteNode *)newStone{
    SKSpriteNode *stone = [SKSpriteNode spriteNodeWithImageNamed:@"Stone"];
    stone.anchorPoint = CGPointZero;
    stone.zPosition = 10;
    return stone;
}
- (SKBButtonNode *)newMenuButton{
    UIImage *a = [UIImage imageNamed:@"MenuButton_Coral_300x110REZ"];
    SKTexture *tx = [SKTexture textureWithImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]];
    SKTexture *tx2 = [SKTexture textureWithImage:[self darkenImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]]];
    SKBButtonNode *play = [[SKBButtonNode alloc] initWithTextureNormal:tx selected:tx2];
    play.position = CGPointMake((CGRectGetMaxX(self.frame) - (75 * scaleFactor)), (130 * scaleFactor));
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
    self.finished = YES;
    self.started = NO;
    [self die];
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























