//
//  SKBViewController.m
//  Sprite Kit Breakout
//
//  Created by Božidar Ševo on 24/05/14.
//  Copyright (c) 2014 Božidar Ševo. All rights reserved.
//

#import "SKBViewController.h"
#import "SKBMyScene.h"

@implementation SKBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO; //set to YES if you do want to see frame rate on screen
    skView.showsNodeCount = NO; // set to YES if you do want to see node count on scren
    
    // Create and configure the scene.
    CGFloat w,h;
    w = skView.bounds.size.width;
    h = skView.bounds.size.height;
    if (h > w) {
        CGFloat tmp = h;
        h = w;
        w = tmp;
    }
    SKScene * scene = [SKBMyScene sceneWithSize:CGSizeMake(w, h)];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
