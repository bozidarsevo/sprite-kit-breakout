//
//  SKBMyScene.h
//  Sprite Kit Breakout
//

//  Copyright (c) 2014 Božidar Ševo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define kPaddleMoveMult 1.5 //multiply factor when moving fingers to move the paddles, by moving finger for N pt it will move it for N * kPaddleMoveMult
#define kBrickInARow 14
#define kNoOfRows 8
#define kSpeedupFactor 1.1

enum {
    SKBGameStateDefault = 1,
    SKBGameStatePlaying = 2,
    SKBGameStateLostLife = 3,
    SKBGameStateReplay = 4
};
typedef NSUInteger SKBGameState;

//categories for detecting contacts between nodes
static const uint32_t ballCategory  = 0x1 << 0;
static const uint32_t brickCategory = 0x1 << 1;
static const uint32_t paddleCategory = 0x1 << 2;
static const uint32_t cornerCategory = 0x1 << 3;

@interface SKBMyScene : SKScene <SKPhysicsContactDelegate>

@end
