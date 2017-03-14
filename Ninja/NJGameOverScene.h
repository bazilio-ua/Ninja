//
//  NJGameOverScene.h
//
//  Created by : Basil Nikityuk
//  Project    : Ninja
//  Date       : 1/14/16
//
//  Copyright (c) 2016 IDAP LLC.
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"

@interface NJGameOverScene : CCScene

+ (CCScene *)sceneWithWon:(BOOL)won;
- (id)initWithWon:(BOOL)won;

@end




