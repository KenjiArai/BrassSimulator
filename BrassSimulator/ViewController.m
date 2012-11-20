//
//  ViewController.m
//  BrassSimulator
//
//  Created by KenjiArai on 2012/10/23.
//  Copyright (c) 2012年 KenjiArai. All rights reserved.
//

#import "ViewController.h"

static const int NOTE_NUM = 33;
static const int ICON_NUM = 3;

@interface ViewController ()
{
    AVAudioPlayer *soundClick;
    UIView *v;
    
    NSTimer *scrollTimer;
    NSTimer *logTimer;

    AVAudioPlayer *soundNote[NOTE_NUM];
    NSMutableArray *melodyIcon;

    NSString *mTitle;
    NSNumber *mTempo;
    NSNumber *mScale;
    
    NSArray *mNote;
    NSArray *mLength;
    NSArray *mActive;

    int idxPlay;
    bool playing;
    
//    float playPosition;
//    
//    BOOL isTimerDidFireSetup;
//    UIImageView *currentIcon;
//    float iconTop;
//    float iconBottom;

    
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path;
    for (int i = 0; i < NOTE_NUM; i++) {
        NSString *noteName = [NSString stringWithFormat:@"%02d", i];
        path = [[NSBundle mainBundle] pathForResource:noteName ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:path];
        soundNote[i] = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//        [soundNote[i] setVolume:0];
//        [soundNote[i] setNumberOfLoops:-1];
//        [soundNote[i] play];

    }
    
    int idxMelody = 1;
    path = [[NSBundle mainBundle] pathForResource:@"userPlayList" ofType:@"plist"];
    NSArray *melody = [NSArray arrayWithContentsOfFile:path];
    mTitle = [[melody[idxMelody] objectForKey:@"Title"] retain];
    mTempo = [[melody[idxMelody] objectForKey:@"Tempo"] retain];
    mScale = [[melody[idxMelody] objectForKey:@"Scale"] retain];
    
    [melodyTilte setText:mTitle];

    mNote = [[melody[idxMelody] objectForKey:@"Note"] retain];
    mLength = [[melody[idxMelody] objectForKey:@"Length"] retain];
    mActive = [[melody[idxMelody] objectForKey:@"Activate"] retain];
    
    [self createNote];
    idxPlay =0;
}


- (void)createNote
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fingeringList" ofType:@"plist"];
    NSArray *fingeringToNote = [NSArray arrayWithContentsOfFile:path];
    int fingering[ICON_NUM];
    
    melodyIcon = [[NSMutableArray alloc] init];
    
    float verticalPoint[ICON_NUM];
    verticalPoint[0] = guide01.center.x;
    verticalPoint[1] = guide02.center.x;
    verticalPoint[2] = guide03.center.x;
    
    float totalLength = 0;
    for (int idxLeng = 0; idxLeng < [mLength count]; idxLeng++) {
        totalLength += [mLength[idxLeng] doubleValue];
    }
    float scrollHeight =  (totalLength * 60) + 660;
    float iconY =  scrollHeight - 330;
    
    mScrollView.frame = CGRectMake(0, 140, 320, 340);
    mScrollView.contentSize = CGSizeMake(320, scrollHeight);
    mScrollView.contentOffset = CGPointMake(0.0f, scrollHeight -340);
    
    float totalIconHeight;
    for (int i = 0; i < [mLength count]; i++) {
        
        int note = [mNote[i] intValue] + [mScale intValue];
        double length = [mLength[i] doubleValue];
        int active = [mActive[i] intValue];
        UIImage *image;
        UIImage *stretchImage;
        
        fingering[0] = [fingeringToNote[note][0] intValue];
        fingering[1] = [fingeringToNote[note][1] intValue];
        fingering[2] = [fingeringToNote[note][2] intValue];
        
        UIImageView *icon[ICON_NUM];
        for (int j = 0; j < ICON_NUM; j++) {
            icon[j] = [[UIImageView alloc] init];
            if (active && (fingering[j] || !(fingering[0]+fingering[1]+fingering[2]))) {
                
                if (note == 6 || note == 13 || note == 18
                || note == 22 || note == 25 || note == 30) {
                    image = [UIImage imageNamed:@"offValve.png"];
                } else {
                    image = [UIImage imageNamed:@"onValve.png"];
                }
                stretchImage = [image stretchableImageWithLeftCapWidth:13 topCapHeight:10];
                icon[j].image = stretchImage;
            }
            icon[j].frame = CGRectMake(0, 0, 27, length * 60);
            icon[j].center = CGPointMake(verticalPoint[j], iconY -icon[j].frame.size.height /2);
            [mScrollView addSubview:icon[j]];
        }
        [melodyIcon addObject:icon[0]];
        float iconHeight = icon[0].frame.size.height;
        iconY -= iconHeight;
        totalIconHeight += iconHeight;
        for (int j = 0; j < ICON_NUM; j++) {
            [icon[j] release];
        }
    }
}

- (IBAction)pushStop:(id)sender
{
    btnPlay.alpha = 1;
    if (idxPlay < [mNote count] ) {
        int note = [mNote[idxPlay] intValue] + [mScale intValue];

        if ([soundNote[note] isPlaying]) {
            [soundNote[note] stop];
            [soundNote[note] setCurrentTime:0];
        }
    }
    if ([scrollTimer isValid]) {
        [scrollTimer invalidate];
        [logTimer invalidate];
    }
}

- (IBAction)pushPlay:(id)sender
{
    btnPlay.alpha = 0;
    
    if (idxPlay >= [mNote count]) {
        btnPlay.alpha = 1;
    } else {
        playing = false;
        scrollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / ([mTempo intValue] /2)
                                                       target:self
                                                     selector:@selector(timerDidFire:)
                                                     userInfo:nil
                                                      repeats:YES];
    }
}

- (void)timerDidFire:(NSTimer*)timer
{
    CGPoint p = mScrollView.contentOffset;
    p.y -= 2;
    mScrollView.contentOffset = p;

    if (idxPlay >= [mNote count]) {
        if (mScrollView.contentOffset.y <= 0 ) {
            btnPlay.alpha = 1;
            [scrollTimer invalidate];
            [logTimer invalidate];
        }
    } else {
        int note = [mNote[idxPlay] intValue] + [mScale intValue];
        int activate = [mActive[idxPlay] intValue];

        UIImageView *currentIcon = melodyIcon[idxPlay];
        float iconTop =  currentIcon.frame.origin.y - p.y;
        float iconBottom = iconTop + currentIcon.frame.size.height;

        float playPosition = mScrollView.frame.size.height - valve01.frame.size.height;

        if (playPosition < iconBottom) {
            if (!playing && activate) {
            [soundNote[note] play];
            playing = true;
            }}
        if (playPosition < iconTop) {
            [soundNote[note] stop];
            [soundNote[note] setCurrentTime:0];
            playing = false;
            idxPlay++;
        }
    }
}

- (void)dealloc
{
    // サウンドの解放処理
    for (int i = 0; i < NOTE_NUM; i++) {
        [soundNote[i] release];
    }
    
    [mTitle release];
    [mTempo release];
    [mScale release];
    [mNote release];
    [mLength release];
    [mActive release];
    
    [scrollTimer release];
    [melodyIcon release];
    
    [super dealloc];
}

- (IBAction)push01:(id)sender
{
    for (int i = 0; i < NOTE_NUM; i++) {
        
        if([soundNote[i] isPlaying]) {
            //再生中は停止する
            [soundNote[i] stop];
            [soundNote[i] setCurrentTime:0];
        }
    }
    [soundNote[0] play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
