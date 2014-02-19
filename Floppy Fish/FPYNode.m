//
//  FPYNode.m
//  Fish Dash
//
//  Created by Andrew Paterson on 2/17/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

#import "FPYNode.h"

@implementation FPYNode
- (id)initWithSize:(CGSize)size{
    self = [super init];
    if (self) {
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:1.0 alpha:0.0] size:size];
        [self addChild:node];
        node.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    }
    return self;
}
@end
