//
//  NJStartScene.m
//
//  Created by : Basil Nikityuk
//  Project    : Ninja
//  Date       : 1/11/16
//
//  Copyright (c) 2016 IDAP LLC.
//  All rights reserved.
//

#import "NJStartScene.h"
#import "NJGameOverScene.h"

static const NSInteger	kNJMinDuration = 2;
static const NSInteger	kNJMaxDuration = 4;
static const CCTime		kNJDefaultTimeInterval = 1.5f;

@interface NJStartScene ()
@property (nonatomic, assign)	NSUInteger	monstersDestroyed;
@property (nonatomic, strong)	CCLabelTTF	*monstersDestroyedLabel;

- (void)setupBackground;
- (void)setupPhysicsWorld;
- (void)setupPlayer;
- (void)addMonsterWithTimeInterval:(CCTime)timeInterval;
- (void)setupMenuItem;
- (void)onMenuButton:(CCButton *)button;
- (void)onMuteMusicButton:(CCButton *)button;
- (void)setupHUDItem;
- (void)updateHUDItem;

@end

@implementation NJStartScene

#pragma mark -
#pragma mark Class Methods

+ (CCScene *)scene {
	return [[self alloc] init];
}

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)dealloc {
	if ([[OALSimpleAudio sharedInstance] bgPlaying]) {
		[[OALSimpleAudio sharedInstance] stopBg];
	}
}

- (id)init {
    self = [super init];
	if (self) {
		self.userInteractionEnabled = YES;
		
		[self setupBackground];
		
		[self setupPhysicsWorld];
		
		[self setupPlayer];
		
		[self setupMenuItem];
		
		[self setupHUDItem];
		
		[self schedule:@selector(addMonsterWithTimeInterval:) interval:kNJDefaultTimeInterval];
		
		[[OALSimpleAudio sharedInstance] playBg:@"background-music-aac.caf" loop:YES];
	}
	
    return self;
}

#pragma mark -
#pragma mark Private Methods

- (void)setupBackground {
	CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor grayColor]];
	
	[self addChild:background];
}

- (void)setupPhysicsWorld {
	CCPhysicsNode *physicsWorld = [CCPhysicsNode node];
	physicsWorld.gravity = ccp(0, 0);
//	physicsWorld.debugDraw = YES;
	physicsWorld.collisionDelegate = self;
	
	[self addChild:physicsWorld];
	self.physicsWorld = physicsWorld;
}

- (void)setupPlayer {
	CCSprite *player = [CCSprite spriteWithImageNamed:@"player-hd.png"];
	player.position = ccp(self.contentSize.width / 8, self.contentSize.height / 2);
	
	CGRect playerRect = {CGPointZero, player.contentSize};
	player.physicsBody = [CCPhysicsBody bodyWithRect:playerRect cornerRadius:0];
	player.physicsBody.collisionGroup = @"playerGroup";
	player.physicsBody.collisionType = @"playerCollision";
	
	[self.physicsWorld addChild:player];
	self.player = player;
}

- (void)addMonsterWithTimeInterval:(CCTime)timeInterval {
	CCSprite *monster = [CCSprite spriteWithImageNamed:@"monster-hd.png"];
	NSInteger minY = monster.contentSize.height / 2;
	NSInteger maxY = self.contentSize.height - minY;
	NSInteger rangeY = maxY - minY;
	NSInteger randomY = arc4random_uniform((u_int32_t)rangeY) + minY;
	monster.position = ccp(self.contentSize.width + monster.contentSize.width / 2, randomY);
	
	CGRect monsterRect = {CGPointZero, monster.contentSize};
	monster.physicsBody = [CCPhysicsBody bodyWithRect:monsterRect cornerRadius:0];
	monster.physicsBody.collisionGroup = @"monsterGroup";
	monster.physicsBody.collisionType = @"monsterCollision";
	
	[self.physicsWorld addChild:monster];
	
	NSInteger rangeDuration = kNJMaxDuration - kNJMinDuration;
	NSInteger randomDuration = arc4random_uniform((u_int32_t)rangeDuration) + kNJMinDuration;
	
	CCAction *actionMove = [CCActionMoveTo actionWithDuration:randomDuration
													 position:ccp(-monster.contentSize.width / 2, randomY)];
	CCAction *actionRemove = [CCActionRemove action];
	[monster runAction:[CCActionSequence actionWithArray:@[actionMove, actionRemove]]];
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
	CGPoint touchLocation = [touch locationInNode:self];
	
	CCSprite *player = self.player;
	CGPoint offset = ccpSub(touchLocation, player.position);
	CGFloat ratio = offset.y / offset.x;
	NSInteger targetX = player.contentSize.width / 2 + self.contentSize.width;
	NSInteger targetY = (targetX * ratio) + player.position.y;
	CGPoint targetPosition = ccp(targetX, targetY);
	
	CCSprite *projectile = [CCSprite spriteWithImageNamed:@"projectile-hd.png"];
	projectile.position = player.position;
	
//	CGRect projectileRect = {CGPointZero, projectile.contentSize};
//	projectile.physicsBody = [CCPhysicsBody bodyWithRect:projectileRect cornerRadius:0];
	projectile.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:projectile.contentSize.width / 2
														 andCenter:projectile.anchorPointInPoints];
	
	projectile.physicsBody.collisionGroup = @"playerGroup";
	projectile.physicsBody.collisionType = @"projectileCollision";
	
	[self.physicsWorld addChild:projectile];
	
	CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:1.5f position:targetPosition];
	CCActionRemove *actionRemove = [CCActionRemove action];
	[projectile runAction:[CCActionSequence actionWithArray:@[actionMove, actionRemove]]];
	
	CCActionRotateBy *actionSpin = [CCActionRotateBy actionWithDuration:0.5f angle:360];
	[projectile runAction:[CCActionRepeatForever actionWithAction:actionSpin]];
	
	[[OALSimpleAudio sharedInstance] playEffect:@"pew-pew-lei.caf"];
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
			   monsterCollision:(CCNode *)monster
			projectileCollision:(CCNode *)projectile
{
	self.monstersDestroyed = self.monstersDestroyed + 1;
	[self updateHUDItem];
	
	[monster removeFromParent];
	[projectile removeFromParent];
	
	if (self.monstersDestroyed >= 10) {
		CCScene *gameOverScene = [NJGameOverScene sceneWithWon:YES];
		[[CCDirector sharedDirector] replaceScene:gameOverScene];
	}
	
	return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
				playerCollision:(CCNode *)player
			   monsterCollision:(CCNode *)monster
{
//	[player removeFromParent];
//	[monster removeFromParent];
	
	CCScene *gameOverScene = [NJGameOverScene sceneWithWon:NO];
	[[CCDirector sharedDirector] replaceScene:gameOverScene];
	
	return NO;
}

- (void)setupMenuItem {
	CCButton *menuButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Tahoma-Bold" fontSize:16.0f];
	NSLog(@"%@", menuButton);
	menuButton.positionType = CCPositionTypeNormalized;
	menuButton.position = ccp(0.90f, 0.95f); // top right of screen
	[menuButton setTarget:self selector:@selector(onMenuButton:)];
	[self addChild:menuButton];
	
	CCButton *muteMusicButton = [CCButton buttonWithTitle:@"[Music ON ]" fontName:@"Tahoma-Bold" fontSize:16.0f];
	muteMusicButton.positionType = CCPositionTypeNormalized;
	muteMusicButton.position = ccp(0.90f, 0.85f);
	[muteMusicButton setTarget:self selector:@selector(onMuteMusicButton:)];
	[self addChild:muteMusicButton];
}

- (void)onMenuButton:(CCButton *)button {
	NSLog(@"%@", button);
}

- (void)onMuteMusicButton:(CCButton *)button {
	NSLog(@"%@", button);
	
	NSString *title = nil;
	if ([[OALSimpleAudio sharedInstance] bgPlaying]) {
		[[OALSimpleAudio sharedInstance] stopBg];
		title = @"[Music OFF]";
	} else {
		[[OALSimpleAudio sharedInstance] playBg:@"background-music-aac.caf" loop:YES];
		title = @"[Music ON ]";
	}
	
	[button setTitle:title];
}

- (void)setupHUDItem {
	NSString *string = [NSString stringWithFormat:@"Monsters: %lu", (unsigned long)self.monstersDestroyed];
	CCLabelTTF *label = [CCLabelTTF labelWithString:string fontName:@"Tahoma-Bold" fontSize:16.0f];
	label.color = [CCColor redColor];
	label.positionType = CCPositionTypeNormalized;
	label.position = ccp(0.10f, 0.95f);
	
	[self addChild:label];
	self.monstersDestroyedLabel = label;
}

- (void)updateHUDItem {
	[self.monstersDestroyedLabel setString:[NSString stringWithFormat:@"Monsters: %lu", (unsigned long)self.monstersDestroyed]];
}

@end
