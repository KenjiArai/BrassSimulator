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

//    NSString *path;
//    NSURL *url;
//    NSArray *melody;
    
    NSString *mTitle;
    NSNumber *mTempo;
    NSNumber *mScale;
    
    NSArray *mNote;
    NSArray *mLength;
    NSArray *mActive;

//    int idxMelody;
//    float iconHeight;
//    float iconTop;
//    float iconBottom;
    int idxPlay;
    bool playing;
    
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *path;
    v = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)] autorelease];
    v.backgroundColor = [UIColor redColor];
    [self.view addSubview:v];
    
    int i;
    for (i = 0; i < NOTE_NUM; i++) {
        NSString *noteName = [NSString stringWithFormat:@"%02d", i];
        path = [[NSBundle mainBundle] pathForResource:noteName ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:path];
        soundNote[i] = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    }
    
    int idxMelody = 2;
    mNote = [[NSArray alloc] init];
    
    path = [[NSBundle mainBundle] pathForResource:@"userPlayList" ofType:@"plist"];
    NSArray *melody = [NSArray arrayWithContentsOfFile:path];
    mTitle = [[melody[idxMelody] objectForKey:@"Title"] retain];
    mTempo = [[melody[idxMelody] objectForKey:@"Tempo"] retain];
    mScale = [[melody[idxMelody] objectForKey:@"Scale"] retain];
    
    [melodyTilte setText:mTitle];

//    mNote = [melody[idxMelody] objectForKey:@"Note"];
//    mLength = [melody[idxMelody] objectForKey:@"Length"];
//    mActive = [melody[idxMelody] objectForKey:@"Activate"];
    mNote = [[melody[idxMelody] objectForKey:@"Note"] retain];
    mLength = [[melody[idxMelody] objectForKey:@"Length"] retain];
    mActive = [[melody[idxMelody] objectForKey:@"Activate"] retain];
    
    [self createNote];
    idxPlay =0;
}


- (void)createNote
{
    
//    path = [[NSBundle mainBundle] pathForResource:@"userPlayList" ofType:@"plist"];
//    melody = [NSArray arrayWithContentsOfFile:path];
//    
//    mScale = [melody[idxMelody] objectForKey:@"Scale"];
    
//    mNote = [melody[idxMelody] objectForKey:@"Note"];
//    mLength = [melody[idxMelody] objectForKey:@"Length"];
//    mActive = [melody[idxMelody] objectForKey:@"Activate"];

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
//    path = [[NSBundle mainBundle] pathForResource:@"userPlayList" ofType:@"plist"];
//    melody = [NSArray arrayWithContentsOfFile:path];
    
//    mScale = [melody[idxMelody] objectForKey:@"Scale"];
//    mNote = [melody[idxMelody] objectForKey:@"Note"];

    btnPlay.alpha = 1;
    if (idxPlay < [mNote count] ) {
        int note = [mNote[idxPlay] intValue] + [mScale intValue];
        NSLog(@"idxPlay = %d", idxPlay);
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
    
//    path = [[NSBundle mainBundle] pathForResource:@"userPlayList" ofType:@"plist"];
//    melody = [NSArray arrayWithContentsOfFile:path];
    
    int tempo = [mTempo
                 intValue];
    
    UIImageView *img = melodyIcon[0];
    NSLog(@"iconY = %f", img.frame.origin.y - mScrollView.contentOffset.y);
    playing = false;
    if (idxPlay >= [mNote count]) {
        btnPlay.alpha = 1;
    } else {
    
        scrollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / tempo
                                                       target:self
                                                     selector:@selector(timerDidFire:)
                                                     userInfo:nil
                                                      repeats:YES];
        logTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                    target:self
                                                  selector:@selector(checkLog:)
                                                  userInfo:nil
                                                   repeats:YES];
    } 
}

- (void)checkLog:(NSTimer*)timer
{
    NSLog(@"y =  %f", mScrollView.contentOffset.y);
    
    UIImageView *img = melodyIcon[0];
    NSLog(@"iconY = %f", img.frame.origin.y - mScrollView.contentOffset.y);
}

- (void)timerDidFire:(NSTimer*)timer
{
//    path = [[NSBundle mainBundle] pathForResource:@"userPlayList" ofType:@"plist"];
//    melody = [NSArray arrayWithContentsOfFile:path];
//        
//    mScale = [melody[idxMelody] objectForKey:@"Scale"];
    
//    mNote = [melody[idxMelody] objectForKey:@"Note"];
//    mLength = [melody[idxMelody] objectForKey:@"Length"];
//    mActive = [melody[idxMelody] objectForKey:@"Activate"];
    
    CGPoint p = mScrollView.contentOffset;
    p.y--;
    mScrollView.contentOffset = p;

    if (idxPlay >= [mNote count]) {
        if (mScrollView.contentOffset.y <= 0 ) {
//            idxPlay--;
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
    [logTimer release];
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
