//
//  ViewController.m
//  BrassSimulator
//
//  Created by KenjiArai on 2012/10/23.
//  Copyright (c) 2012年 KenjiArai. All rights reserved.
//

#import "PlayViewController.h"

static const int NOTE_NUM = 33;
static const int ICON_NUM = 3;
static const int ICON_HEIGHT_AJST = 60;
static const int ICON_V_BLANK = 330;

@interface PlayViewController ()
{
    AVAudioPlayer *soundClick;
    UIView *v;
    
    NSTimer *scrollTimer;
    NSTimer *playTimer;
    
    AVAudioPlayer *soundNote[NOTE_NUM];

    NSArray *fingeringToNote;
    NSMutableArray *melodyFingering;
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
    bool tap[ICON_NUM];
    int deff[ICON_NUM];
    
    float playPosition;
    
    BOOL isTimerDidFireSetup;
    UIImageView *currentIcon;
    float iconTop;
    float iconBottom;
    float scrollInterval;
}
@end

@implementation PlayViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
    }
}

- (void)viewDidLoad
{
//    [super viewDidLoad];
    
    NSString *noteName;
    NSString *path;
    
    self.view.multipleTouchEnabled = YES;
    
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
    
    NSString *mPath = [[NSBundle mainBundle] pathForResource:@"userPlayList" ofType:@"plist"];
    NSArray *melody = [NSArray arrayWithContentsOfFile:mPath];
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
    int fingering[ICON_NUM];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fingeringList" ofType:@"plist"];
    fingeringToNote = [NSArray arrayWithContentsOfFile:path];
    
    melodyIcon = [[NSMutableArray alloc] init];
    
    float verticalPoint[ICON_NUM];
    verticalPoint[0] = guide01.center.x;
    verticalPoint[1] = guide02.center.x;
    verticalPoint[2] = guide03.center.x;
    
    float totalLength = 0;
    for (int idxLeng = 0; idxLeng < [mLength count]; idxLeng++) {
        totalLength += [mLength[idxLeng] doubleValue];
    }
    float scrollHeight =  (totalLength * ICON_HEIGHT_AJST) + ICON_V_BLANK *2;
    float iconY =  scrollHeight - ICON_V_BLANK;
    
    mScrollView.frame = CGRectMake(0, 140, 320, 340);
    mScrollView.contentSize = CGSizeMake(320, scrollHeight);
    mScrollView.contentOffset = CGPointMake(0.0f, scrollHeight -(ICON_V_BLANK+10));
    
    melodyFingering = [[NSMutableArray array] retain];
    
    float totalIconHeight;
    for (int i = 0; i < [mLength count]; i++) {
        
        int note = [mNote[i] intValue] + [mScale intValue];
        double length = [mLength[i] doubleValue];
        int active = [mActive[i] intValue];
        UIImage *image;
        UIImage *stretchImage;
        [melodyFingering addObject:fingeringToNote[note]];
        fingering[0] = [fingeringToNote[note][0] intValue];
        fingering[1] = [fingeringToNote[note][1] intValue];
        fingering[2] = [fingeringToNote[note][2] intValue];
//        NSString *f = [NSString stringWithFormat:@"%d%d%d", fingering[0], fingering[1], fingering[2]];
        
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
            icon[j].frame = CGRectMake(0, 0, 27, length * ICON_HEIGHT_AJST);
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
        [playTimer invalidate];
        
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
        [playTimer invalidate];
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
                currentIcon = melodyIcon[i];
                firstIcon = img;
                break;
            }
        }
        float timerInterval = 1.0 / 60;
        scrollTimer = [[NSTimer scheduledTimerWithTimeInterval:timerInterval
                                                       target:self
                                                     selector:@selector(timerDidFire:)
                                                     userInfo:nil
                                                       repeats:YES] retain];
        playTimer = [[NSTimer scheduledTimerWithTimeInterval:timerInterval
                                                      target:self
                                                    selector:@selector(timerDidPlay:)
                                                    userInfo:nil
                                                     repeats:YES] retain];
    }
}

- (void)timerDidPlay:(NSTimer*)timer
{
    if (idxPlay < mNote.count) {
        int note = [mNote[idxPlay] intValue] + [mScale intValue];
        if (playing && soundNote[note].volume == 0) {
            [soundNote[note] setCurrentTime:0];
            [soundNote[note] setVolume:1.0];
        }
    }
}
- (void)timerDidFire:(NSTimer*)timer
{
    
    float aa = [mTempo intValue] / 60;
    CGPoint p = mScrollView.contentOffset;
    p.y -= aa;
    mScrollView.contentOffset = p;
//    iconTop += aa;
//    iconBottom += aa;
    
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
            [playTimer invalidate];
        }
    } else {
        
//        currentIcon = melodyIcon[idxPlay];
        iconTop =  currentIcon.frame.origin.y - p.y;
        iconBottom = iconTop + currentIcon.frame.size.height;
        if (playPosition < iconBottom) {
            
//            int note = [mNote[idxPlay] intValue] + [mScale intValue];
//            int activate = [mActive[idxPlay] intValue];
            if (!playing &&  [mActive[idxPlay] intValue]) { // activate) {
                
//                [soundNote[note] setCurrentTime:0];
//                //                if ( ![soundNote[note] isPlaying] ) {
//                //                    [soundNote[note] play];
//                //                }
//                [soundNote[note] setVolume:1.0];
                playing = true;
//                p.y -= 1;
//                mScrollView.contentOffset = p;
//                iconTop += 1;
//                iconBottom += 1;
            }
        }
        if (playPosition < iconTop) {

            int note = [mNote[idxPlay] intValue] + [mScale intValue];
            //[soundNote[note] pause];
            [soundNote[note] setVolume:0];
            playing = false;
            idxPlay++;
            if ( idxPlay < mNote.count ) {
                
                currentIcon = melodyIcon[idxPlay];
                iconTop =  currentIcon.frame.origin.y - p.y;
                iconBottom = iconTop + [mLength[0] doubleValue] *60;

//                if (iconTop -playPosition == 1) {
//                    iconTop = playPosition - ([mLength[idxPlay] doubleValue] *60 -1);
//                    iconBottom = playPosition -1;
//                } else {
//                    iconTop = playPosition - ([mLength[idxPlay] doubleValue] * ICON_HEIGHT_AJST -aa);
//                    iconBottom = playPosition -aa;
                
//                }
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
    [playTimer release];
    
    
    [super dealloc];
}

- (IBAction)pushGuideMode:(id)sender
{
    btnGuideMode.alpha = 0;
}

- (IBAction)pushPlayMode:(id)sender
{
    btnGuideMode.alpha = 1;
}

- (IBAction)valveDown:(id)sender
{
    int idx;
    int deffValue = 0;
    if (sender == valve01.self) {
        idx = 0;
        deffValue = 2;
    } else if (sender == valve02.self) {
        idx = 1;
        deffValue = 1;
    } else if (sender == valve03.self) {
        idx = 2;
        deffValue = 3;
    }
    
    tap[idx] = true;
    if ([[[melodyFingering objectAtIndex:idxPlay] objectAtIndex:0] intValue] == 0) {
        deff[idx] = deffValue;
    }
    NSLog(@"valve = %d, deff = %d", idx, deffValue);

}

- (IBAction)valveUp:(id)sender
{

    int idx;
    int deffValue = 0;
    
    if (sender == valve01.self) {
        idx = 0;
        deffValue = -2;
    } else if (sender == valve02.self) {
        idx = 1;
        deffValue = -1;
    } else if (sender == valve03.self) {
        idx =2;
        deffValue = -3;
    }
    
    tap[idx] = false;
    if ([[[melodyFingering objectAtIndex:idxPlay] objectAtIndex:0] intValue] == 1) {
        deff[idx] = deffValue;
    }
    NSLog(@"valve = %d, deff = %d", idx, deffValue);

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
