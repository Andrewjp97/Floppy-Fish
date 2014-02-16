//
//  FPYScoreFormatter.h
//  Floppy Fish
//
//  Created by Andrew Paterson on 2/3/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SpriteKit;

@interface FPYScoreFormatter : NSObject
+ (instancetype)sharedFormatter;
    ///Returns sprite containing the score in numbers
- (SKSpriteNode *)scoreNumbersForScore:(NSInteger)score highScore:(NSInteger)highScore ScaleFactor:(float)scaleFactor;
- (SKSpriteNode *)nodeForScore:(NSInteger)score scaleFactor:(float)scaleFactor;
- (void)dumpCore;
@end
