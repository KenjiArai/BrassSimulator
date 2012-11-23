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
    
    AVAudioPlayer *soundNote[NOTE_NUM];
    NSMutableArray *melodyIcon;
    UIImageView *firstIcon;
    
    NSString *mTitle;
    NSNumber *mTempo;
    NSNumber *mScale;
    
    NSArray *mNote;
    NSArray *mLength;
    NSArray *mActive;

    int idxPlay;
    bool playing;
    
    float playPosition;
    
    BOOL isTimerDidFireSetup;
    UIImageView *currentIcon;
    float iconTop;
    float iconBottom;
    float scrollInterval;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
//    [super viewDidLoad];
    
    NSString *noteName;
    NSString *path;
    
    for (int i = 0; i < NOTE_NUM; i++) {
        noteName = [NSString stringWithFormat:@"%02d", i];
        path = [[NSBundle mainBundle] pathForResource:noteName ofType:@"aiff"];
        NSURL *url = [NSURL fileURLWithPath:path];
        soundNote[i] = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        //        [soundNote[i] prepareToPlay];
        [soundNote[i] setVolume:0];
        [soundNote[i] setNumberOfLoops:-1];
        [soundNote[i] play];
    }
    
    int idxMelody = 1;
    mNote = [[NSArray alloc] init];
    
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
//    idxPlay =0;
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
//        if (i == 0) {
//            firstIcon = icon[0];
//        }
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
    for (int i = 0; i < NOTE_NUM; i++) {
        [soundNote[i] setVolume:0];
    }
    if ([scrollTimer isValid]) {
        [scrollTimer invalidate];
    }
    [melodyIcon release];
    btnPlay.alpha = 1;
    idxPlay = 0;
    [self createNote];
}

- (IBAction)pushPose:(id)sender
{
    btnPlay.alpha = 1;
    if (idxPlay < [mNote count] ) {
        int note = [mNote[idxPlay] intValue] + [mScale intValue];
        if ([soundNote[note] isPlaying]) {
            [soundNote[note] setVolume:0];
            [soundNote[note] setCurrentTime:0];
            playing = false;
        }
    }
    if ([scrollTimer isValid]) {
        [scrollTimer invalidate];
    }
}

- (IBAction)pushPlay:(id)sender
{
    UIImageView *img;
    btnPlay.alpha = 0;
    
    playing = false;
    if (idxPlay >= [mNote count]) {
        btnPlay.alpha = 1;
    } else {
        
        playPosition = mScrollView.frame.size.height - valve01.frame.size.height;

        for (int i = 0; i < melodyIcon.count; i++) {
            img = melodyIcon[i];
            iconTop = img.frame.origin.y - mScrollView.contentOffset.y;
            iconBottom = iconTop + img.frame.size.height;
            if (iconBottom <= playPosition) {
                idxPlay = i;
                firstIcon = img;
                break;
            }
        }
        scrollTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 / ([mTempo intValue] / 2.0 )
                                                       target:self
                                                     selector:@selector(timerDidFire:)
                                                     userInfo:nil
                                                      repeats:YES] retain];
    }
}

- (void)timerDidFire:(NSTimer*)timer
{
    CGPoint p = mScrollView.contentOffset;
    p.y -= 2;
    mScrollView.contentOffset = p;
    iconTop += 2;
    iconBottom += 2;
    
//    if ( !isTimerDidFireSetup ) {
//        currentIcon = melodyIcon[idxPlay];
//        iconTop =  currentIcon.frame.origin.y - p.y;
//        iconBottom = iconTop + [mLength[0] doubleValue] *60;
//        isTimerDidFireSetup = YES;
//    }
    
    if (idxPlay >= mNote.count) {
        if (mScrollView.contentOffset.y <= 0 ) {
            btnPlay.alpha = 1;
            [scrollTimer invalidate];
        }
    } else {
        
//        iconTop =  currentIcon.frame.origin.y - p.y;
//        iconBottom = iconTop + currentIcon.frame.size.height;
        if (playPosition < iconBottom) {
            
            int note = [mNote[idxPlay] intValue] + [mScale intValue];
            int activate = [mActive[idxPlay] intValue];
            iconTop = iconTop;
            if (!playing && activate) {
                [soundNote[note] setCurrentTime:0];
                //                if ( ![soundNote[note] isPlaying] ) {
                //                    [soundNote[note] play];
                //                }
                [soundNote[note] setVolume:1.0];
                playing = true;
            }
        }
        if (playPosition < iconTop) {
            int note = [mNote[idxPlay] intValue] + [mScale intValue];
            //[soundNote[note] pause];
            [soundNote[note] setVolume:0];
            playing = false;
            idxPlay++;
            if ( idxPlay < mNote.count ) {
                iconTop = playPosition - ([mLength[idxPlay] doubleValue] *60 -2);
                iconBottom = playPosition -2;
//                currentIcon = melodyIcon[idxPlay];
//                iconTop = currentIcon.frame.origin.y - p.y;
//                iconBottom = iconTop + currentIcon.frame.size.height;
            }
        }
    }
}

- (void)next:(NSNumber*)prev
{
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"userPlayList" ofType:@"plist"];
    //    NSArray *melody = [NSArray arrayWithContentsOfFile:path];
    //
    //    NSNumber *mTempo = [melody[1] objectForKey:@"Tempo"];
    //    NSNumber *mScale = [melody[1] objectForKey:@"Scale"];
    //
    //    NSArray *mNote = [melody[1] objectForKey:@"Note"];
    //    NSArray *mLength = [melody[1] objectForKey:@"Length"];
    //    NSArray *mActivate = [melody[1] objectForKey:@"Activate"];
    
    int note;
    int no = [prev intValue];
    
    //    int noteNo = no + [scale intValue];
    if ( no > -1 ) {
        note = [mNote[no] intValue] + [mScale intValue];
        [soundNote[note] stop];
        [soundNote[note] setCurrentTime:0];
    }
    
    no++;
    if ( [mActive count] <= no ) return;
    
    note = [mNote[no] intValue] + [mScale intValue];
    double melodyLength = [mLength[no] doubleValue] / ([mTempo intValue] / 60);
    
    if ([mActive[no] intValue]) {
        [soundNote[note] play];
    }
    
    [self performSelector:@selector(next:) withObject:[NSNumber numberWithInt:no] afterDelay:melodyLength];
}

- (void)runloop:(id)sender
{
    int x = v.center.x;
    int y = v.center.y;
    v.center = CGPointMake(x +1, y +1);
    //    y= 0;
    int scrollTop = mScrollView.frame.origin.y;
    int scrollHeight =mScrollView.frame.size.height;
    mScrollView.frame = CGRectMake(0, scrollTop +1, 320, scrollHeight +11);
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
    
    [super dealloc];
}

- (IBAction)push01:(id)sender
{
    for (int i = 0; i < NOTE_NUM; i++) {
        
        //再生中は停止する
        [soundNote[i] setVolume:0];
        [soundNote[i] setCurrentTime:0];
    }
    [soundNote[0] setVolume:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
