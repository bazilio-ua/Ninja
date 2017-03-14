//
//  NJGameOverScene.m
//
//  Created by : Basil Nikityuk
//  Project    : Ninja
//  Date       : 1/14/16
//
//  Copyright (c) 2016 IDAP LLC.
//  All rights reserved.
//

#import "NJGameOverScene.h"
#import "NJStartScene.h"

static const CCTime		kNJDefaultDuration = 3.0f;

@interface NJGameOverScene ()

- (void)setupBackground;
- (void)setupLabelWithMessage:(NSString *)message;
- (void)doAction;

@end

@implementation NJGameOverScene

+ (CCScene *)sceneWithWon:(BOOL)won {
    return [[self alloc] initWithWon:won];
}

- (id)initWithWon:(BOOL)won {
    self = [super init];
	if (self) {
		self.userInteractionEnabled = YES;
		
		[self setupBackground];
		
		NSString *message = won ? @"You Won!" : @ "You Lose :[";
		[self setupLabelWithMessage:message];
		
		[self doAction];
	}
	
    return self;
}

#pragma mark -
#pragma mark Private Methods

- (void)setupBackground {
	CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor whiteColor]];
	
	[self addChild:background];
}

- (void)setupLabelWithMessage:(NSString *)message {
//	CGSize viewSize = [CCDirector sharedDirector].viewSize;
	CCLabelTTF *label = [CCLabelTTF labelWithString:message fontName:@"Tahoma-Bold" fontSize:32.0f];
	label.color = [CCColor blackColor];
	label.positionType = CCPositionTypeNormalized;
	label.position = ccp(0.5f, 0.5f);
//	label.position = ccp(viewSize.width / 2, viewSize.height / 2);
	
	[self addChild:label];
}

- (void)doAction {
	CCActionDelay *actionDelay = [CCActionDelay actionWithDuration:kNJDefaultDuration];
	CCActionCallBlock *actionBlock = [CCActionCallBlock actionWithBlock:^{
		[[CCDirector sharedDirector] replaceScene:[NJStartScene scene]];
	}];
	
	[self runAction:[CCActionSequence actionWithArray:@[actionDelay, actionBlock]]];
}

@end
