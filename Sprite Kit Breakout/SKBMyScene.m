//
//  SKBMyScene.m
//  Sprite Kit Breakout
//
//  Created by Božidar Ševo on 24/05/14.
//  Copyright (c) 2014 Božidar Ševo. All rights reserved.
//

#import "SKBMyScene.h"

@interface SKBMyScene()

//node for score labels
@property(nonatomic) SKNode *hudNode;
@property(nonatomic) SKLabelNode *bricksCountLabelNode;
@property(nonatomic) SKLabelNode *scoreCountLabelNode;
@property(nonatomic) SKLabelNode *lifeCountLabelNode;
//game area node
@property(nonatomic) SKNode *gameAreaNode;
//bricks
@property(nonatomic) SKNode *bricksNode;
//paddle and ball
@property(nonatomic) SKSpriteNode *paddleNode;
@property(nonatomic) SKSpriteNode *ballNode;
//replay node
@property(nonatomic) SKSpriteNode *replayNode;

//score, life count etc
@property(nonatomic) NSUInteger scoreCount;
@property(nonatomic) NSUInteger lifeCount;

//values for brick dimensions etc...
//brick dimensions are (widthPart x heightPart/2)
@property(nonatomic) CGFloat widthPart;
@property(nonatomic) CGFloat heightPart;

@property(nonatomic) SKBGameState gameState;

//sounds
@property(nonatomic) SKAction *bounceSoundAction;
@property(nonatomic) SKAction *failSoundAction;

@end

@implementation SKBMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;

        self.backgroundColor = [SKColor blackColor];
        
        //dimension stuff
        self.heightPart = size.height / 12.0;
        self.widthPart = (size.width - 2 * self.heightPart) / 14.0;
        
        //game state
        self.gameState = SKBGameStateDefault;
        
        [self setupHudNode];
        [self setupGameAreaNode];
        
        //sound actions
        self.bounceSoundAction = [SKAction playSoundFileNamed:@"app_game_interactive_alert_tone_026.mp3" waitForCompletion:NO];
        self.failSoundAction = [SKAction playSoundFileNamed:@"synth_stab.mp3" waitForCompletion:NO];

    }
    return self;
}

-(void)setupHudNode
{
    self.hudNode = [SKNode node];
    //replay node
    self.replayNode = [SKSpriteNode spriteNodeWithImageNamed:@"restartNode.png"];
    self.replayNode.size = CGSizeMake(self.heightPart / 2.0, self.heightPart / 2.0);
    self.replayNode.position = CGPointMake(self.heightPart / 2.0, self.size.height - self.heightPart / 2.0);
    [self.hudNode addChild:self.replayNode];
    //bricks count
    self.bricksCountLabelNode = [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter"];
    self.bricksCountLabelNode.fontColor = [SKColor whiteColor];
    self.bricksCountLabelNode.fontSize = self.heightPart / 2.0;
    self.bricksCountLabelNode.position = CGPointMake(self.size.width * 0.25, self.size.height - self.heightPart / 2.0);
    [self.hudNode addChild:self.bricksCountLabelNode];
    //score count
    self.scoreCountLabelNode = [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter"];
    self.scoreCountLabelNode.fontColor = [SKColor whiteColor];
    self.scoreCountLabelNode.fontSize = self.bricksCountLabelNode.fontSize;
    self.scoreCountLabelNode.position = CGPointMake(self.size.width * 0.5, self.size.height - self.heightPart / 2.0);
    [self.hudNode addChild:self.scoreCountLabelNode];
    //life count
    self.lifeCountLabelNode = [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter"];
    self.lifeCountLabelNode.fontColor = [SKColor whiteColor];
    self.lifeCountLabelNode.fontSize = self.bricksCountLabelNode.fontSize;
    self.lifeCountLabelNode.position = CGPointMake(self.size.width * 0.75, self.size.height - self.heightPart / 2.0);
    [self.hudNode addChild:self.lifeCountLabelNode];
    
    [self addChild:self.hudNode];
}

-(void)setupGameAreaNode
{
    self.gameAreaNode = [SKNode node];
    [self addChild:self.gameAreaNode];
    
    //game area border
    SKSpriteNode *leftBorder = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(self.heightPart, 11.0 * self.heightPart)];
    leftBorder.position = CGPointMake(self.heightPart / 2.0, self.heightPart * 5.5);
    leftBorder.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leftBorder.size];
    leftBorder.physicsBody.dynamic = NO;
    leftBorder.physicsBody.categoryBitMask = cornerCategory;
    [self.gameAreaNode addChild:leftBorder];
    SKSpriteNode *rightBorder = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:leftBorder.size];
    rightBorder.position = CGPointMake(self.size.width - self.heightPart / 2.0, self.heightPart * 5.5);
    rightBorder.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightBorder.size];
    rightBorder.physicsBody.dynamic = NO;
    rightBorder.physicsBody.categoryBitMask = cornerCategory;
    [self.gameAreaNode addChild:rightBorder];
    SKSpriteNode *upperBorder = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(self.size.width, self.heightPart)];
    upperBorder.position = CGPointMake(self.size.width / 2.0, self.heightPart * 10.5);
    upperBorder.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:upperBorder.size];
    upperBorder.physicsBody.dynamic = NO;
    upperBorder.physicsBody.categoryBitMask = cornerCategory;
    [self.gameAreaNode addChild:upperBorder];
    
    //PADDLE
    self.paddleNode = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(self.widthPart * 2.0, self.heightPart * 0.25)];
    self.paddleNode.position = CGPointMake(self.size.width / 2.0, self.paddleNode.size.height);
    self.paddleNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.paddleNode.size];
    self.paddleNode.physicsBody.dynamic = NO;
    self.paddleNode.physicsBody.friction = 1.0;
    self.paddleNode.physicsBody.categoryBitMask = paddleCategory;
    [self.gameAreaNode addChild:self.paddleNode];

    //BALL
    self.ballNode = [SKSpriteNode spriteNodeWithImageNamed:@"circleNode.png"];
    self.ballNode.size = CGSizeMake(self.widthPart * 0.3, self.widthPart * 0.3);
    self.ballNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.ballNode.size.width / 2.0];
    self.ballNode.physicsBody.linearDamping = 0.0;
    self.ballNode.physicsBody.angularDamping = 0.0;
    self.ballNode.physicsBody.restitution = 1.0;
    self.ballNode.physicsBody.dynamic = YES;
    self.ballNode.physicsBody.friction = 0.0;
    self.ballNode.physicsBody.allowsRotation = NO;
    self.ballNode.physicsBody.categoryBitMask = ballCategory;
    self.ballNode.physicsBody.contactTestBitMask = brickCategory | paddleCategory | cornerCategory;
    
    [self setupBricksNode];
}

-(void)setupBricksNode
{
    self.bricksNode = [SKNode node];
    [self.gameAreaNode addChild:self.bricksNode];
}

-(void)addBricksToGame
{
    [self.bricksNode removeAllChildren];
    SKColor *brickColor;
    NSString *brickColorName;
    CGSize brickSize = CGSizeMake(self.widthPart, self.heightPart / 2.0);
    CGPoint brickPosition = CGPointMake(self.heightPart + brickSize.width / 2.0, self.heightPart * 4.0 + brickSize.height / 2.0);
    for (NSUInteger i = 0; i < kNoOfRows; i++) {
        switch (i) {
            case 0:
            case 1:
                brickColor = [SKColor yellowColor];
                brickColorName = @"yellow";
                break;
            case 2:
            case 3:
                brickColor = [SKColor greenColor];
                brickColorName = @"green";
                break;
            case 4:
            case 5:
                brickColor = [SKColor orangeColor];
                brickColorName = @"orange";
                break;
            case 6:
            case 7:
                brickColor = [SKColor redColor];
                brickColorName = @"red";
                break;
            default:
                break;
        }
        for (NSUInteger j = 0; j < kBrickInARow; j++) {
            SKSpriteNode *brick = [SKSpriteNode spriteNodeWithColor:brickColor size:brickSize];
            brick.position = brickPosition;
            brick.name = brickColorName;
            brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brickSize];
            brick.physicsBody.dynamic = NO;
            brick.physicsBody.categoryBitMask = brickCategory;
            [self.bricksNode addChild:brick];
            
            brickPosition.x += brickSize.width;
        }
        brickPosition.y += brickSize.height;
        brickPosition.x = self.heightPart + brickSize.width / 2.0;
    }
    [self updateHudLabels];
}

-(void)updateHudLabels
{
    self.bricksCountLabelNode.text = [NSString stringWithFormat:@"Bricks: %d",self.bricksNode.children.count];
    self.scoreCountLabelNode.text = [NSString stringWithFormat:@"Score: %d",self.scoreCount];
    self.lifeCountLabelNode.text = [NSString stringWithFormat:@"Life: %d",self.lifeCount];
}

-(void)replayGame
{
    [self.ballNode removeFromParent];
    self.gameState = SKBGameStateReplay;
    [self startNewGame];
    [self addBricksToGame];
}

-(void)lostOneLife
{
    if (self.lifeCount--)
    {
        self.gameState = SKBGameStateLostLife;
        [self updateHudLabels];
    }
    else
    {
        self.gameState = SKBGameStateLostLife;
        [self startNewGame];
        [self addBricksToGame];
    }
}

-(void)speedupTheBall
{
    CGFloat dx = self.ballNode.physicsBody.velocity.dx;
    CGFloat dy = self.ballNode.physicsBody.velocity.dy;
    dx *= kSpeedupFactor;
    dy *= kSpeedupFactor;
    self.ballNode.physicsBody.velocity = CGVectorMake(dx, dy);
}

-(void)addPlayingBall
{
    self.gameState = SKBGameStatePlaying;

    CGPoint ballPosition = self.paddleNode.position;
    ballPosition.y += self.ballNode.size.height;
    self.ballNode.position = ballPosition;
    CGFloat dx = 50;
    CGFloat dy = 75;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        dx *= 2.0;
        dy *= 2.0;
    }
    self.ballNode.physicsBody.velocity = CGVectorMake(dx, dy);
    [self.gameAreaNode addChild:self.ballNode];
}

-(void)startNewGame
{
    self.scoreCount = 0;
    self.lifeCount = 2;
    
    //update hud
    [self updateHudLabels];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    switch (self.gameState) {
        case SKBGameStateDefault:
            //start playing
            [self startNewGame];
            [self addBricksToGame];
            [self addPlayingBall];
            break;
        case SKBGameStatePlaying:
            //
            if (CGRectContainsPoint(self.replayNode.frame, location)) {
                [self replayGame];
            }
            break;
        case SKBGameStateLostLife:
            //start new play since you lost one life
            [self addPlayingBall];
            break;
        case SKBGameStateReplay:
            //replay button tapped, just add playing ball
            [self addPlayingBall];
        default:
            break;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint newLocation = [touch locationInNode:self];
    CGPoint previousLocation = [touch previousLocationInNode:self];
//    NSLog(@"moved to %@",NSStringFromCGPoint(newLocation));
    CGFloat y = self.paddleNode.position.y;
    CGFloat x = self.paddleNode.position.x + (newLocation.x - previousLocation.x) * kPaddleMoveMult;
    CGFloat xMax = self.size.width - self.heightPart - self.paddleNode.size.width / 2.0;
    CGFloat xMin = self.heightPart + self.paddleNode.size.width / 2.0;
    if (x > xMax)
    {
        x = xMax;
    }
    else if(x < xMin)
    {
        x = xMin;
    }
    self.paddleNode.position = CGPointMake(x, y);
}

#pragma mark physics

-(void)didSimulatePhysics
{
    if (self.ballNode.position.y < 0 && self.ballNode.parent) {
        [self runAction:self.failSoundAction];
        [self.ballNode removeFromParent];
        [self lostOneLife];
    }
}

-(void)removeBrickNode:(SKNode*)brick
{
    NSUInteger points = 1;
    if ([brick.name isEqualToString:@"green"]) {
        points = 3;
    }
    else if ([brick.name isEqualToString:@"orange"])
    {
        points = 5;
    }
    else if ([brick.name isEqualToString:@"red"])
    {
        points = 7;
    }
    self.scoreCount += points;
    
    [brick removeFromParent];
    
    NSInteger brickCount = self.bricksNode.children.count;
    if ((brickCount % 4 == 0)) {
        [self speedupTheBall];
    }
}

//react to contact between nodes/bodies
-(void)didBeginContact:(SKPhysicsContact*)contact
{
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == cornerCategory)
    {
        //sound
        [self runAction:self.bounceSoundAction];
    }
    else if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == brickCategory)
    {
        SKNode *brickNode = [secondBody node];
        [self removeBrickNode:brickNode];
        [self updateHudLabels];
        //sound
        [self runAction:self.bounceSoundAction];
    }
    else if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory)
    {
        //sound
        [self runAction:self.bounceSoundAction];
    }
}
-(void)didEndContact:(SKPhysicsContact*)contact
{
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory)
    {
        CGPoint ballPosition = self.ballNode.position;
        CGFloat firstThird = (self.paddleNode.position.x - self.paddleNode.size.width / 2.0) + self.paddleNode.size.width * (1.0/3.0);
        CGFloat secondThird = (self.paddleNode.position.x - self.paddleNode.size.width / 2.0) + self.paddleNode.size.width * (2.0/3.0);
        CGFloat dx = self.ballNode.physicsBody.velocity.dx;
        CGFloat dy = self.ballNode.physicsBody.velocity.dy;
        //        NSLog(@"velocity poslije %f %f",dx,dy);
        if (ballPosition.x < firstThird) {
            //ball hits the left part
            if (dx > 0) {
                self.ballNode.physicsBody.velocity = CGVectorMake(-dx, dy);
            }
        }
        else if (ballPosition.x > secondThird) {
            //ball hits the left part
            if (dx < 0) {
                self.ballNode.physicsBody.velocity = CGVectorMake(-dx, dy);
            }
        }
    }
    else if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory)
    {
    }
}

//-(void)update:(CFTimeInterval)currentTime {
//    /* Called before each frame is rendered */
//}

@end
