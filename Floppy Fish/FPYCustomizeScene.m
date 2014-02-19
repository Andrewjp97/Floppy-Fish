//
//  FPYCustomizeScene.m
//  Fish Dash
//
//  Created by Andrew Paterson on 2/16/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

#import "FPYCustomizeScene.h"
#import "FPYMyScene.h"
#import "SKBButtonNode.h"
#import <Crashlytics/Crashlytics.h>

@implementation FPYCustomizeScene{
    float scaleFactor;
}
- (id)initWithSize:(CGSize)size{
    self = [super initWithSize:size];
    if (self) {
        if (!self.sceneContentCreated) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                scaleFactor = 2.0;
            }
            else{
                scaleFactor = 1.0;
            }
            [self createSceneContent];
            self.sceneContentCreated = YES;
        }
    }
    return self;
}
- (void)createSceneContent{
    FPYAppDelegate *ddd = [[UIApplication sharedApplication] delegate];
    [self addChild:[self newBackgroundNode]];
    self.selectedFishColor = ddd.fishColor;
    [self selectedFishDidChange];
    [self addChild:[self newMenuButton]];
    SKSpriteNode *fish1 = [self newFishForColor:FPYFishColorDefault];
    fish1.position = CGPointMake(CGRectGetMaxX(self.frame) / 4, (CGRectGetMaxY(self.frame) / 4) * 3);
    [self addChild:fish1];
    SKSpriteNode *fish2 = [self newFishForColor:FPYFishColorRed];
    fish2.position = CGPointMake((CGRectGetMaxX(self.frame) / 4) * 3, (CGRectGetMaxY(self.frame) / 4) * 3);
    [self addChild:fish2];
    SKSpriteNode *fish3 = [self newFishForColor:FPYFishColorGreen];
    fish3.position = CGPointMake(CGRectGetMaxX(self.frame) / 4, (CGRectGetMaxY(self.frame) / 2));
    [self addChild:fish3];
    SKSpriteNode *fish4 = [self newFishForColor:FPYFishColorPurple];
    fish4.position = CGPointMake((CGRectGetMaxX(self.frame) / 4) * 3, (CGRectGetMaxY(self.frame) /2));
    [self addChild:fish4];
    SKSpriteNode *fish5 = [self newFishForColor:FPYFishColorPink];
    fish5.position = CGPointMake(CGRectGetMaxX(self.frame) / 4, (CGRectGetMaxY(self.frame) / 4));
    [self addChild:fish5];
    SKSpriteNode *fish6 = [self newFishForColor:FPYFishColorBlue];
    fish6.position = CGPointMake((CGRectGetMaxX(self.frame) / 4) * 3, CGRectGetMaxY(self.frame) / 4);
    [self addChild:fish6];
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
- (SKSpriteNode *)newBackgroundNode{
    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"CustomizeBackground"];
    bg.anchorPoint = CGPointZero;
    return bg;
}
- (SKBButtonNode *)newMenuButton{
    UIImage *a = [UIImage imageNamed:@"MenuButton_Coral_300x110REZ"];
    SKTexture *tx = [SKTexture textureWithImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]];
    SKTexture *tx2 = [SKTexture textureWithImage:[self darkenImage:[self imageWithImage:a convertToSize:CGSizeMake(90 * scaleFactor, 30 * scaleFactor)]]];
    SKBButtonNode *play = [[SKBButtonNode alloc] initWithTextureNormal:tx selected:tx2];
    play.position = CGPointMake((70 * scaleFactor), (60 * scaleFactor));
    [play setTouchUpInsideTarget:self action:@selector(menuButtonPressed)];
    return play;
}
- (void)menuButtonPressed{
    FPYMyScene *myScene = [[FPYMyScene alloc] initWithSize:self.size];
    SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.5];
    [self.view presentScene:myScene transition:transition];
}
- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
        //return image;

}
- (NSString *)imageForFishTwoWithColor:(FPYFishColor)color{

    switch (color) {
        case FPYFishColorDefault:
            return @"fishTwo";
            break;
        case FPYFishColorPurple:
            return @"PurpleFishTwo";
            break;
        case FPYFishColorGreen:
            return @"GreenFishTwo";
            break;
        case FPYFishColorBlue:
            return @"BlueFishTwo";
            break;
        case FPYFishColorPink:
            return @"PinkFishTwo";
            break;
        case FPYFishColorRed:
            return @"RedFishTwo";
            break;
    }
}
- (NSString *)nameOfImageFishForColor:(FPYFishColor)color{
    switch (color) {
        case FPYFishColorDefault:
            return @"fish";
            break;
        case FPYFishColorPurple:
            return @"PurpleFish";
            break;
        case FPYFishColorGreen:
            return @"GreenFish";
            break;
        case FPYFishColorBlue:
            return @"BlueFish";
            break;
        case FPYFishColorPink:
            return @"PinkFish";
            break;
        case FPYFishColorRed:
            return @"RedFish";
            break;
    }
}
- (SKSpriteNode *)newFishForColor:(FPYFishColor)color{
    SKSpriteNode *fish = [SKSpriteNode spriteNodeWithImageNamed:[self nameOfImageFishForColor:color]];
    SKAction *animate = [SKAction animateWithTextures:@[[SKTexture textureWithImageNamed:[self nameOfImageFishForColor:color]], [SKTexture textureWithImageNamed:[self imageForFishTwoWithColor:color]]] timePerFrame:0.25];
    SKAction *repeat = [SKAction repeatActionForever:animate];
    fish.name = [NSString stringWithFormat:@"%d", color];
    [fish runAction:repeat];
    return fish;
}
- (void)selectedFishDidChange{
    SKSpriteNode *fish1 = (SKSpriteNode *)[self childNodeWithName:@"1"];
    [fish1 removeAllChildren];
    SKSpriteNode *fish2 = (SKSpriteNode *)[self childNodeWithName:@"2"];
    [fish2 removeAllChildren];
    SKSpriteNode *fish3 = (SKSpriteNode *)[self childNodeWithName:@"3"];
    [fish3 removeAllChildren];
    SKSpriteNode *fish4 = (SKSpriteNode *)[self childNodeWithName:@"4"];
    [fish4 removeAllChildren];
    SKSpriteNode *fish5 = (SKSpriteNode *)[self childNodeWithName:@"5"];
    [fish5 removeAllChildren];
    SKSpriteNode *fish6 = (SKSpriteNode *)[self childNodeWithName:@"6"];
    [fish6 removeAllChildren];

    switch (self.selectedFishColor) {
        case FPYFishColorDefault:
            [[NSUserDefaults standardUserDefaults] setObject:@"default" forKey:@"fishColor"];
            break;
        case FPYFishColorRed:
            [[NSUserDefaults standardUserDefaults] setObject:@"red" forKey:@"fishColor"];
            break;
        case FPYFishColorGreen:
            [[NSUserDefaults standardUserDefaults] setObject:@"green" forKey:@"fishColor"];
            break;
        case FPYFishColorPink:
            [[NSUserDefaults standardUserDefaults] setObject:@"pink" forKey:@"fishColor"];
            break;
        case FPYFishColorPurple:
            [[NSUserDefaults standardUserDefaults] setObject:@"purple" forKey:@"fishColor"];
            break;
        case FPYFishColorBlue:
            [[NSUserDefaults standardUserDefaults] setObject:@"blue" forKey:@"fishColor"];
            break;
    }
    SKSpriteNode *fish = (SKSpriteNode *)[self childNodeWithName:[NSString stringWithFormat:@"%d", self.selectedFishColor]];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sparkle" ofType:@"sks"];
    SKEmitterNode *sparkle = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    sparkle.name = @"sparkle";
    [fish addChild:sparkle];
    sparkle.position = CGPointMake(0, -(CGRectGetHeight(fish.frame)) - 10);
    FPYAppDelegate *appD = [[UIApplication sharedApplication] delegate];
    appD.fishColor = self.selectedFishColor;
    NSLog(@"%d", self.selectedFishColor);
    [[NSUserDefaults standardUserDefaults] synchronize];

}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [Crashlytics setObjectValue:[touches anyObject] forKey:@"touch"];
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    [super touchesBegan:touches withEvent:event];
    SKSpriteNode *fish1 = (SKSpriteNode *)[self childNodeWithName:@"1"];
    if ([fish1 containsPoint:location]) {
        self.selectedFishColor = FPYFishColorDefault;
        [self selectedFishDidChange];
    }
    SKSpriteNode *fish2 = (SKSpriteNode *)[self childNodeWithName:@"2"];
    if ([fish2 containsPoint:location]) {
        self.selectedFishColor = FPYFishColorRed;
        [self selectedFishDidChange];
    }
    SKSpriteNode *fish3 = (SKSpriteNode *)[self childNodeWithName:@"3"];
    if ([fish3 containsPoint:location]) {
        self.selectedFishColor = FPYFishColorGreen;
        [self selectedFishDidChange];
    }
    SKSpriteNode *fish4 = (SKSpriteNode *)[self childNodeWithName:@"4"];
    if ([fish4 containsPoint:location]) {
        self.selectedFishColor = FPYFishColorPurple;
        [self selectedFishDidChange];
    }
    SKSpriteNode *fish5 = (SKSpriteNode *)[self childNodeWithName:@"5"];
    if ([fish5 containsPoint:location]) {
        self.selectedFishColor = FPYFishColorPink;
        [self selectedFishDidChange];
    }
    SKSpriteNode *fish6 = (SKSpriteNode *)[self childNodeWithName:@"6"];
    if ([fish6 containsPoint:location]) {
        self.selectedFishColor = FPYFishColorBlue;
        [self selectedFishDidChange];
    }
}

@end
