//
//  FPYMyScene.m
//  Floppy Fish
//
//  Created by Andrew Paterson on 1/29/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

#import "FPYMyScene.h"

@implementation FPYMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        

    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    [super touchesBegan:touches withEvent:event];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
