//
//  ViewController.h
//  BrassSimulator
//
//  Created by KenjiArai on 2012/10/23.
//  Copyright (c) 2012年 KenjiArai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface PlayViewController : UIViewController<UIScrollViewDelegate, UIScrollViewAccessibilityDelegate>
{
//    IBOutlet UILabel *melodyTilte;
    

    IBOutlet UIButton *btnPlay;
    IBOutlet UIButton *btnStop;
    IBOutlet UIButton *btnPlayMode;
    IBOutlet UIButton *btnGuideMode;
    IBOutlet UIScrollView *mScrollView;
    IBOutlet UIImageView *guide01;
    IBOutlet UIImageView *guide02;
    IBOutlet UIImageView *guide03;
    IBOutlet UITextField *melodyTilte;
    IBOutlet UITextField *melodyScale;
    IBOutlet UITextField *melodyTempo;
    IBOutlet UIStepper *noteSteper;
    IBOutlet UIButton *valve01;
    IBOutlet UIButton *valve02;
    IBOutlet UIButton *valve03;
}

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end