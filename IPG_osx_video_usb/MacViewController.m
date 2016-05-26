//
//  MacViewController.m
//  IPG_osx_video_usb
//
//  Created by Jason Dunne, Gene Han on 3/30/15.
//  Copyright (c) 2015 Limitless. All rights reserved.
//

#import "MacViewController.h"

static void *AVSPPlayerItemStatusContext = &AVSPPlayerItemStatusContext;
static void *AVSPPlayerRateContext = &AVSPPlayerRateContext;
static void *AVSPPlayerLayerReadyForDisplay = &AVSPPlayerLayerReadyForDisplay;

@interface MacViewController (){
    int _videoNum;
}
@end

@implementation MacViewController

- (void)viewDidAppear{
    ((MacWindow*)[[self view] window]).windowDelegate = self;
    self.window = (MacWindow*)[[self view] window];
    
    _isLooping = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onIpadInc:) name:@"IPAD_INC" object:nil];
    [self loadVideoAsset];
    
}

- (void) onIpadInc:(NSNotification *) noti{
    NSDictionary * ipadInfo = noti.userInfo;
    NSString * msg = [ipadInfo objectForKey:@"IPAD_INC"];
    NSLog(@"[MAC_VIEW] ipad msg inc:%@", msg);
    NSString * numStr = msg;
    if( [numStr isEqualToString:@"x0"]){
        _videoNum = 0;
    }else if( [numStr isEqualToString:@"x1"]){
        _videoNum = 1;
    }else if( [numStr isEqualToString:@"x2"]){
        _videoNum = 2;
        
    }else if( [numStr isEqualToString:@"x3"]){
        _videoNum = 3;
        
    }else if( [numStr isEqualToString:@"x4"]){
        _videoNum = 4;
    }else if( [numStr isEqualToString:@"x5"]){
        _videoNum = 5;
    }
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(switchVideoTo) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _videoNum = 1;
    
    _isVideoLoaded = false;
    
    self.playerView.layer.backgroundColor = CGColorGetConstantColor(kCGColorBlack);
    
}


- (void) loadVideoAsset{
    if( _isVideoLoaded ){
        return;
    }
    _isVideoLoaded = true;
    
    _player = [[AVPlayer alloc]init];
    [self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew context:AVSPPlayerRateContext];
    [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:AVSPPlayerItemStatusContext];
    
    _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_player currentItem]];
    
    
    
    
    // video assets
    NSURL* video1URL = [NSURL fileURLWithPath:@"/Users/ipglab/Documents/IPG_osx_ios/IPG_osx_video_usb/Resources/1-Start.mov"];
    AVURLAsset *asset1 = [AVAsset assetWithURL:video1URL];
    _video1 = [AVPlayerItem playerItemWithAsset:asset1];
    
    NSURL* video2URL = [NSURL fileURLWithPath:@"/Users/ipglab/Documents/IPG_osx_ios/IPG_osx_video_usb/Resources/2-CarlsJR.mov"];
    AVURLAsset *asset2 = [AVAsset assetWithURL:video2URL];
    _video2 = [AVPlayerItem playerItemWithAsset:asset2];
    
    
    NSURL* video3URL = [NSURL fileURLWithPath:@"/Users/ipglab/Documents/IPG_osx_ios/IPG_osx_video_usb/Resources/3-CVS.mov"];
    AVURLAsset *asset3 = [AVAsset assetWithURL:video3URL];
    _video3 = [AVPlayerItem playerItemWithAsset:asset3];
    
    NSURL* video4URL = [NSURL fileURLWithPath:@"/Users/ipglab/Documents/IPG_osx_ios/IPG_osx_video_usb/Resources/4-Home.mov"];
    AVURLAsset *asset4 = [AVAsset assetWithURL:video4URL];
    _video4 = [AVPlayerItem playerItemWithAsset:asset4];
    
    NSURL* video5URL = [NSURL fileURLWithPath:@"/Users/ipglab/Documents/IPG_osx_ios/IPG_osx_video_usb/Resources/5-Home_new.mov"];
    AVURLAsset *asset5 = [AVAsset assetWithURL:video5URL];
    _video5 = [AVPlayerItem playerItemWithAsset:asset5];
    
    _videoNum = 1;
    
    
    
    // video layer
    [_playerView setFrame:NSMakeRect(0, 0, 3840, 2160)];
    AVPlayerLayer *newPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    newPlayerLayer.frame = NSMakeRect(0, 0, 3840, 2160);
    newPlayerLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    [self.playerView.layer addSublayer:newPlayerLayer];
    self.playerLayer = newPlayerLayer;
    [self addObserver:self forKeyPath:@"playerLayer.readyForDisplay" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVSPPlayerLayerReadyForDisplay];
    
    [self.player replaceCurrentItemWithPlayerItem:_video1];
    
    
}


- (void)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys
{
    // This method is called when the AVAsset for our URL has completing the loading of the values of the specified array of keys.
    // We set up playback of the asset here.
    
    // First test whether the values of each of the keys we need have been successfully loaded.
    for (NSString *key in keys)
    {
        NSError *error = nil;
        
        if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed)
        {
            [self stopAllShowError:error];
            return;
        }
    }
    
    if (![asset isPlayable] || [asset hasProtectedContent])
    {
        // We can't play this asset. Show the "Unplayable Asset" label.
        [self stopAllShowError:nil];
        return;
    }
    
    // We can play this asset.
    // Set up an AVPlayerLayer according to whether the asset contains video.
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0)
    {
        // Create an AVPlayerLayer and add it to the player view if there is video, but hide it until it's ready for display
        NSLog(@"[PV] frame- %f, %f, %f, %f", _playerView.frame.origin.x, _playerView.frame.origin.y, _playerView.frame.size.width, _playerView.frame.size.height);
        [_playerView setFrame:NSMakeRect(0, 0, 3840, 2160)];
        AVPlayerLayer *newPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        newPlayerLayer.frame = NSMakeRect(0, 0, 3840, 2160);
        newPlayerLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
        newPlayerLayer.hidden = YES;
        [self.playerView.layer addSublayer:newPlayerLayer];
        self.playerLayer = newPlayerLayer;
        [self addObserver:self forKeyPath:@"playerLayer.readyForDisplay" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AVSPPlayerLayerReadyForDisplay];
    }
    else
    {
        // This asset has no video tracks. Show the "No Video" label.
        [self stopAllShowError:nil];
    }
    
    // Create a new AVPlayerItem and make it our player's current item.
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    // If needed, configure player item here (example: adding outputs, setting text style rules, selecting media options) before associating it with a player
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    
    
}



- (void) stopAllShowError:(NSError *) error{
    if (error)
    {
        NSLog(@"Error: %@", error.description);
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVSPPlayerItemStatusContext)
    {
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        BOOL enable = NO;
        switch (status)
        {
            case AVPlayerItemStatusUnknown:
                break;
            case AVPlayerItemStatusReadyToPlay:
                enable = YES;
                //     [self.player play];
                break;
            case AVPlayerItemStatusFailed:
                [self stopAllShowError:[[[self player] currentItem] error]];
                break;
        }
        
        //   self.playPauseButton.enabled = enable;
        //   self.fastForwardButton.enabled = enable;
        //   self.rewindButton.enabled = enable;
    }
    else if (context == AVSPPlayerRateContext)
    {
        float rate = [change[NSKeyValueChangeNewKey] floatValue];
        if (rate != 1.f)
        {
            //   self.playPauseButton.title = @"Play";
        }
        else
        {
            //    self.playPauseButton.title = @"Pause";
        }
    }
    else if (context == AVSPPlayerLayerReadyForDisplay)
    {
        if ([change[NSKeyValueChangeNewKey] boolValue] == YES)
        {
            // The AVPlayerLayer is ready for display. Hide the loading spinner and show it.
            [self stopAllShowError:nil];
            self.playerLayer.hidden = NO;
            NSLog(@"[MVC] AVSPPlayerLayerReadyForDisplay");
            
            
            //   [_player play];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}





#pragma mark - NSWindowDelegate
- (void)windowDidResize:(NSNotification *)notification{
    NSLog(@"[MVC] windowDidResize");
}

- (void)windowDidEnterFullScreen:(NSNotification *)notification{
    NSLog(@"[MVC] enter FULL SCREEN");
 //   [self loadVideoAsset];
    _videoNum = 0;
    [self switchVideoTo];
}

- (void)windowDidExitFullScreen:(NSNotification *)notification{
    NSLog(@"[MVC} exit FULL SCREEN");
    [_playerView setFrame:_window.frame];
    [_playerLayer setFrame:_window.frame];
}



#pragma mark - IBACtion
- (void) switchVideoTo{
    [self cancelNotimessage];
    if( _videoNum == 0){
        if( _isLooping ){
            [_player removeTimeObserver:_loopObserver];
            _isLooping = false;
        }
        [_video1 seekToTime:kCMTimeZero];
        [self.player replaceCurrentItemWithPlayerItem:_video1];
        
        CMTime interval = CMTimeMake(175, 100);  // 30fps
        __weak typeof(self) weakSelf = self; // prevent memory cycle
        _loopObserver = [_player addBoundaryTimeObserverForTimes:@[ [NSValue valueWithCMTime:interval]]
                                                           queue:nil
                                                      usingBlock:^{
                                                          [weakSelf.video1 seekToTime:kCMTimeZero];
                                                      }];
        _isLooping = true;
        
        _videoNum = 1;
        [_player play];
        
        NSLog(@"[MVC] pause vid 1");
    }else if( _videoNum == 1){
        if( _isLooping ){
            [_player removeTimeObserver:_loopObserver];
            _isLooping = false;
        }
        [_video1 seekToTime:kCMTimeZero];
        [self.player replaceCurrentItemWithPlayerItem:_video1];
        _videoNum = 1;
        [_player play];
        NSLog(@"[MVC] play vid 1");
        [self sendNotiMessage:@"nCJ" inSec:28.f];
    }else if( _videoNum == 2){
        if( _isLooping ){
            [_player removeTimeObserver:_loopObserver];
            _isLooping = false;
        }
        [_video2 seekToTime:kCMTimeZero];
        [self.player replaceCurrentItemWithPlayerItem:_video2];
        _videoNum = 2;
        [_player play];
        NSLog(@"[MVC] play vid 2");
    }else if( _videoNum == 3){
        if( _isLooping ){
            [_player removeTimeObserver:_loopObserver];
            _isLooping = false;
        }
        [_video3 seekToTime:kCMTimeZero];
        [self.player replaceCurrentItemWithPlayerItem:_video3];
        _videoNum = 3;
        [_player play];
        NSLog(@"[MVC] play vid 3");
    }else if( _videoNum == 4){
        if( _isLooping ){
            [_player removeTimeObserver:_loopObserver];
            _isLooping = false;
        }
        [_video4 seekToTime:kCMTimeZero];
        [self.player replaceCurrentItemWithPlayerItem:_video4];
        _videoNum = 4;
        [_player play];
        NSLog(@"[MVC] play vid 4");
        [self sendNotiMessage:@"nCVS" inSec:1.f];
        [self sendNotiEndInSec:31.f];
        
    }else if( _videoNum == 5 ){
        if( _isLooping ){
            [_player removeTimeObserver:_loopObserver];
            _isLooping = false;
        }
        [_video5 seekToTime:kCMTimeZero];
        [self.player replaceCurrentItemWithPlayerItem:_video5];
        _videoNum = 5;
        [_player play];
        NSLog(@"[MVC] play vid 5");
    }
}


- (void) switchVideo:(id)sender{
    NSLog(@"[MVC] switch play %i", (_videoNum +1)%3);
    if( _videoNum == 1){
        [self.player replaceCurrentItemWithPlayerItem:_video1];
        _videoNum = 2;
        [_player play];
        NSLog(@"[MVC] switch play 2");
    }else if( _videoNum == 2){
        [self.player replaceCurrentItemWithPlayerItem:_video2];
        _videoNum = 2;
        [_player play];
        NSLog(@"[MVC] switch play 3");
    }else if( _videoNum == 3){
        [self.player replaceCurrentItemWithPlayerItem:_video3];
        _videoNum = 3;
        [_player play];
        NSLog(@"[MVC] switch play 4");
    }else{
        [self.player replaceCurrentItemWithPlayerItem:_video4];
        _videoNum = 4;
        [_player play];
        NSLog(@"[MVC] switch play 1");
    }
    
}
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"y%d",_videoNum] forKey:@"IPAD_OUT"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IPAD_OUT" object:nil userInfo:userInfo];
}

- (void) sendNotiEndInSec:(CGFloat) wait{
    [_endTimer invalidate];
    _endTimer = [NSTimer scheduledTimerWithTimeInterval:wait target:self selector:@selector(sendNotiEnd) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_endTimer forMode:NSRunLoopCommonModes];
}


- (void) sendNotiMessage:(NSString*) msg inSec:(CGFloat) wait{
    [_timer invalidate];
    
    if( [msg isEqualToString:@"nCJ" ]){
        _timer = [NSTimer scheduledTimerWithTimeInterval:wait target:self selector:@selector(sendNotiCJ) userInfo:nil repeats:NO];
    }else{
        _timer = [NSTimer scheduledTimerWithTimeInterval:wait target:self selector:@selector(sendNotiCVS) userInfo:nil repeats:NO];
    }
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void) cancelNotimessage{
    [_timer invalidate];
}


- (void) sendNotiCJ{
    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:@"nCJ" forKey:@"IPAD_OUT"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IPAD_OUT" object:nil userInfo:userInfo];
}

- (void) sendNotiCVS{
    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:@"nCVS" forKey:@"IPAD_OUT"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IPAD_OUT" object:nil userInfo:userInfo];
}

- (void) sendNotiEnd{
    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:@"nEnd" forKey:@"IPAD_OUT"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IPAD_OUT" object:nil userInfo:userInfo];
}






@end
