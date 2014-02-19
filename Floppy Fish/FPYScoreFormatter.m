//
//  FPYScoreFormatter.m
//  Floppy Fish
//
//  Created by Andrew Paterson on 2/3/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

#import "FPYScoreFormatter.h"
@import SpriteKit;
@import UIKit;
@interface FPYScoreFormatter ()
@property (strong, nonatomic)NSMutableDictionary *scoreTextures1;
@property (strong, nonatomic)NSMutableDictionary *scoreTextures2;
@property (strong, nonatomic)NSMutableDictionary *scoreSprites1;
@property (strong, nonatomic)NSMutableDictionary *scoreSprites2;
@end


@implementation FPYScoreFormatter
+ (instancetype)sharedFormatter{

    static dispatch_once_t onceToken;
    static id sharedInstance;
dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
});
    return sharedInstance;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        dispatch_async(dispatch_queue_create("com.andrewpaterson.textures", NULL), ^{
            [self preloadTextureFiles];
        });
        
    }
    return self;
}
- (void)preloadTextureFiles;
{
    self.scoreTextures2 = [NSMutableDictionary dictionary];
    for (int i = 0; i < 10; i++) {
        SKTexture *texture = [SKTexture textureWithImage:[self imageWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d", i]] convertToSize:CGSizeMake(64, 64)]];
        [self.scoreTextures2 setValue:texture forKey:[NSString stringWithFormat:@"%d", i]];
    }
    self.scoreTextures1 = [NSMutableDictionary dictionary];
    for (int i = 0; i < 10; i++) {
        SKTexture *texture = [SKTexture textureWithImage:[self imageWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d", i]] convertToSize:CGSizeMake(32, 32)]];
        [self.scoreTextures1 setValue:texture forKey:[NSString stringWithFormat:@"%d", i]];
    }
    [self preloadSprites];
}
- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
        //return image;

}
- (void)preloadSprites{
    self.scoreSprites2 = [NSMutableDictionary dictionary];
    for (int i = 0; i < 10; i++) {
      SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[self.scoreTextures2 objectForKey:[NSString stringWithFormat:@"%d", i]]];
        [self.scoreSprites2 setValue:sprite forKey:[NSString stringWithFormat:@"%d", i]];
    }
    self.scoreSprites1 = [NSMutableDictionary dictionary];
    for (int i = 0; i < 10; i++) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[self.scoreTextures1 objectForKey:[NSString stringWithFormat:@"%d", i]]];
        [self.scoreSprites1 setValue:sprite forKey:[NSString stringWithFormat:@"%d", i]];
    }
}
- (SKSpriteNode *)nodeForScore:(NSInteger)score scaleFactor:(float)scaleFactor{
    SKSpriteNode *returnNode = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:1.0 alpha:0.0] size:CGSizeMake(0 * scaleFactor, 0 * scaleFactor)];
        //TODO:Rest
    if (!self.scoreSprites1) {
        [self preloadTextureFiles];
    }
    if (scaleFactor == 1.0){
        SKSpriteNode *hundreds = [[self.scoreSprites1 objectForKey:[NSString stringWithFormat:@"%d", score/100]] copy];
        [returnNode addChild:hundreds];
        hundreds.position = CGPointMake(10, 16);
        if ((score/100) == 0) {
            [returnNode removeAllChildren];
        }
        SKSpriteNode *tens = [[self.scoreSprites1 objectForKey:[NSString stringWithFormat:@"%d", (score % 100)/10]] copy];
        [returnNode addChild:tens];
        tens.position = CGPointMake(32, 16);
        if (((score % 100)/10) == 0 && (!hundreds)) {
            [returnNode removeChildrenInArray:@[tens]];
        }
        SKSpriteNode *ones = [[self.scoreSprites1 objectForKey:[NSString stringWithFormat:@"%d", (score % 10)]] copy];
        [returnNode addChild:ones];
        ones.position = CGPointMake(54, 16);
    }
    else if (scaleFactor == 2.0){
        SKSpriteNode *hundreds = [[self.scoreSprites2 objectForKey:[NSString stringWithFormat:@"%d", score/100]] copy];
        [returnNode addChild:hundreds];
        hundreds.position = CGPointMake(20, 32);
        if ((score/100) == 0) {
            [returnNode removeAllChildren];
        }
        SKSpriteNode *tens = [[self.scoreSprites2 objectForKey:[NSString stringWithFormat:@"%d", (score % 100)/10]] copy];
        [returnNode addChild:tens];
        tens.position = CGPointMake(64, 32);
        if (((score % 100)/10) == 0 && (!hundreds)) {
            [returnNode removeChildrenInArray:@[tens]];
        }
        SKSpriteNode *ones = [[self.scoreSprites2 objectForKey:[NSString stringWithFormat:@"%d", (score % 10)]] copy];
        [returnNode addChild:ones];
        ones.position = CGPointMake(108, 32);
    }
    else{
        NSLog(@"Improper Scale Factor - Exiting with error code: 2");
        exit(2);
    }
    return returnNode;
}
- (SKSpriteNode *)scoreNumbersForScore:(NSInteger)score highScore:(NSInteger)highScore ScaleFactor:(float)scaleFactor{

    if (score < 10) {
            //Make empty plaque
        UIImage *empty = [UIImage imageNamed:@"NoMedalScreen_750x400"];
        empty = [self imageWithImage:empty convertToSize:CGSizeMake(300 * scaleFactor, 150 * scaleFactor)];
        SKSpriteNode *gameOver = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:empty]];
        SKSpriteNode *returnNode = [self nodeForScore:score scaleFactor:scaleFactor];
        [gameOver addChild:returnNode];
        returnNode.position = CGPointMake(50 * scaleFactor, 0 * scaleFactor);
        SKSpriteNode *other = [self nodeForScore:highScore scaleFactor:scaleFactor];
        [gameOver addChild:other];
        other.position = CGPointMake(50 * scaleFactor, -55 * scaleFactor);
        return gameOver;

    }
    else if (score < 20){
        UIImage *empty = [UIImage imageNamed:@"BronzeMedalScreen_750x400"];
        empty = [self imageWithImage:empty convertToSize:CGSizeMake(300 * scaleFactor, 150 * scaleFactor)];
        SKSpriteNode *gameOver = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:empty]];
        SKSpriteNode *returnNode = [self nodeForScore:score scaleFactor:scaleFactor];
        [gameOver addChild:returnNode];
        returnNode.position = CGPointMake(50 * scaleFactor, 0 * scaleFactor);
        SKSpriteNode *other = [self nodeForScore:highScore scaleFactor:scaleFactor];
        [gameOver addChild:other];
        other.position = CGPointMake(50 * scaleFactor, -55 * scaleFactor);
        return gameOver;
    }
    else if (score < 30){
        UIImage *empty = [UIImage imageNamed:@"SilverMedalScreen_750x400"];
        empty = [self imageWithImage:empty convertToSize:CGSizeMake(300 * scaleFactor, 150 * scaleFactor)];
        SKSpriteNode *gameOver = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:empty]];
        SKSpriteNode *returnNode = [self nodeForScore:score scaleFactor:scaleFactor];
        [gameOver addChild:returnNode];
        returnNode.position = CGPointMake(50 * scaleFactor, 0 * scaleFactor);
        SKSpriteNode *other = [self nodeForScore:highScore scaleFactor:scaleFactor];
        [gameOver addChild:other];
        other.position = CGPointMake(50 * scaleFactor, -55 * scaleFactor);
        return gameOver;
    }
    else if (score < 40){
        UIImage *empty = [UIImage imageNamed:@"GoldMedalScreen_750x400"];
        empty = [self imageWithImage:empty convertToSize:CGSizeMake(300 * scaleFactor, 150 * scaleFactor)];
        SKSpriteNode *gameOver = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:empty]];
        SKSpriteNode *returnNode = [self nodeForScore:score scaleFactor:scaleFactor];
        [gameOver addChild:returnNode];
        returnNode.position = CGPointMake(50 * scaleFactor, 0 * scaleFactor);
        SKSpriteNode *other = [self nodeForScore:highScore scaleFactor:scaleFactor];
        [gameOver addChild:other];
        other.position = CGPointMake(50 * scaleFactor, -55 * scaleFactor);
        return gameOver;
    }
    else if (score < 100){
        UIImage *empty = [UIImage imageNamed:@"PearlMedalScreen_750x400"];
        empty = [self imageWithImage:empty convertToSize:CGSizeMake(300 * scaleFactor, 150 * scaleFactor)];
        SKSpriteNode *gameOver = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:empty]];
        SKSpriteNode *returnNode = [self nodeForScore:score scaleFactor:scaleFactor];
        [gameOver addChild:returnNode];
        returnNode.position = CGPointMake(50 * scaleFactor, 0 * scaleFactor);
        SKSpriteNode *other = [self nodeForScore:highScore scaleFactor:scaleFactor];
        [gameOver addChild:other];
        other.position = CGPointMake(50 * scaleFactor, -55 * scaleFactor);
        return gameOver;
    }
    else{
        UIImage *empty = [UIImage imageNamed:@"AtlantisMedalScreen_750x400"];
        empty = [self imageWithImage:empty convertToSize:CGSizeMake(300 * scaleFactor, 150 * scaleFactor)];
        SKSpriteNode *gameOver = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:empty]];
        SKSpriteNode *returnNode = [self nodeForScore:score scaleFactor:scaleFactor];
        [gameOver addChild:returnNode];
        returnNode.position = CGPointMake(50 * scaleFactor, 0 * scaleFactor);
        SKSpriteNode *other = [self nodeForScore:highScore scaleFactor:scaleFactor];
        [gameOver addChild:other];
        other.position = CGPointMake(50 * scaleFactor, -55 * scaleFactor);
        return gameOver;
    }
    return nil;
}
- (void)dumpCore{
    self.scoreTextures1 = nil;
    self.scoreTextures2 = nil;
    self.scoreSprites1 = nil;
    self.scoreSprites2 = nil;
    NSLog(@"Core resources for %@ have been dumped", self);
}
@end
