//
//
//  Courtesy of Graf on Stack Overflow
//
//
//
#import "SKBButtonNode.h"
#import <objc/message.h>


@implementation SKBButtonNode

#pragma mark Texture Initializer

/**
 * Override the super-classes designated initializer, to get a properly set SKButton in every case
 */
- (instancetype)initWithTexture:(SKTexture *)texture color:(UIColor *)color size:(CGSize)size {
    return [self initWithTextureNormal:texture selected:nil disabled:nil];
}

- (instancetype)initWithTextureNormal:(SKTexture *)normal selected:(SKTexture *)selected {
    return [self initWithTextureNormal:normal selected:selected disabled:nil];
}

/**
 * This is the designated Initializer
 */
- (instancetype)initWithTextureNormal:(SKTexture *)normal selected:(SKTexture *)selected disabled:(SKTexture *)disabled {
    self = [super initWithTexture:normal color:[UIColor whiteColor] size:normal.size];
    if (self) {
        [self setNormalTexture:normal];
        [self setSelectedTexture:selected];
        [self setDisabledTexture:disabled];
        [self setIsEnabled:YES];
        [self setIsSelected:NO];

        _title = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        [_title setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [_title setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];

        [self addChild:_title];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

#pragma mark Image Initializer

- (instancetype)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected {
    return [self initWithImageNamedNormal:normal selected:selected disabled:nil];
}

- (instancetype)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected disabled:(NSString *)disabled {
    SKTexture *textureNormal = nil;
    if (normal) {
        textureNormal = [SKTexture textureWithImageNamed:normal];
    }

    SKTexture *textureSelected = nil;
    if (selected) {
        textureSelected = [SKTexture textureWithImageNamed:selected];
    }

    SKTexture *textureDisabled = nil;
    if (disabled) {
        textureDisabled = [SKTexture textureWithImageNamed:disabled];
    }

    return [self initWithTextureNormal:textureNormal selected:textureSelected disabled:textureDisabled];
}




#pragma -
#pragma mark Setting Target-Action pairs

- (void)setTouchUpInsideTarget:(id)target action:(SEL)action {
    _targetTouchUpInside = target;
    _actionTouchUpInside = action;
}

- (void)setTouchDownTarget:(id)target action:(SEL)action {
    _targetTouchDown = target;
    _actionTouchDown = action;
}

- (void)setTouchUpTarget:(id)target action:(SEL)action {
    _targetTouchUp = target;
    _actionTouchUp = action;
}

#pragma -
#pragma mark Setter overrides

- (void)setIsEnabled:(BOOL)isEnabled {
    _isEnabled = isEnabled;
    if ([self disabledTexture]) {
        if (!_isEnabled) {
            [self setTexture:_disabledTexture];
        } else {
            [self setTexture:_normalTexture];
        }
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if ([self selectedTexture] && [self isEnabled]) {
        if (_isSelected) {
            [self setTexture:_selectedTexture];
        } else {
            [self setTexture:_normalTexture];
        }
    }
}

#pragma -
#pragma mark Touch Handling

/**
 * This method only occurs, if the touch was inside this node. Furthermore if
 * the Button is enabled, the texture should change to "selectedTexture".
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEnabled]) {
        objc_msgSend(_targetTouchDown, _actionTouchDown);
        [self setIsSelected:YES];
    }
}

/**
 * If the Button is enabled: This method looks, where the touch was moved to.
 * If the touch moves outside of the button, the isSelected property is restored
 * to NO and the texture changes to "normalTexture".
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEnabled]) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInNode:self.parent];

        if (CGRectContainsPoint(self.frame, touchPoint)) {
            [self setIsSelected:YES];
        } else {
            [self setIsSelected:NO];
        }
    }
}

/**
 * If the Button is enabled AND the touch ended in the buttons frame, the
 * selector of the target is run.
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInNode:self.parent];

    if ([self isEnabled] && CGRectContainsPoint(self.frame, touchPoint)) {
        objc_msgSend(_targetTouchUpInside, _actionTouchUpInside);
    }
    [self setIsSelected:NO];
    objc_msgSend(_targetTouchUp, _actionTouchUp);
}
@end