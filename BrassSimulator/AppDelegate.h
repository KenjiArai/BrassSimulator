//
//  AppDelegate.h
//  BrassSimulator
//
//  Created by KenjiArai on 2012/10/23.
//  Copyright (c) 2012年 KenjiArai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TopViewController;
@class SelectViewController;
@class PlayViewController;
@class CreateViewController;
@class MastarViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TopViewController *topViewController;
@property (strong, nonatomic) SelectViewController *selectViewController;
@property (strong, nonatomic) PlayViewController *playViewController;
@property (strong, nonatomic) CreateViewController *createViewController;
@property (strong, nonatomic) UINavigationController *masterViewController;


@end
