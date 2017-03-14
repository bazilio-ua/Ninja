//
//  NJStartScene.h
//
//  Created by : Basil Nikityuk
//  Project    : Ninja
//  Date       : 1/11/16
//
//  Copyright (c) 2016 IDAP LLC.
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"

@interface NJStartScene : CCScene <CCPhysicsCollisionDelegate>
@property (nonatomic, strong)   CCSprite		*player;
@property (nonatomic, strong)	CCPhysicsNode	*physicsWorld;

+ (NJStartScene *)scene;
- (id)init;

@end
