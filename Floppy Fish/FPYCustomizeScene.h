//
//  FPYCustomizeScene.h
//  Fish Dash
//
//  Created by Andrew Paterson on 2/16/14.
//  Copyright (c) 2014 Andrew Paterson. All rights reserved.
//

@import SpriteKit;
#include "FPYAppDelegate.h"

@interface FPYCustomizeScene : SKScene
@property (assign, nonatomic)BOOL sceneContentCreated;
@property (nonatomic, assign)FPYFishColor selectedFishColor;

@end
