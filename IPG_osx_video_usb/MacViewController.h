//
//  MacViewController.h
//  IPG_osx_video_usb
//
//  Created by Jason Dunne, Gene Han on 3/30/15.
//  Copyright (c) 2015 Limitless. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MacWindow.h"
#import <AVFoundation/AVFoundation.h>

@class AVPlayer, AVPlayerLayer;

@interface MacViewController : NSViewController<NSWindowDelegate>


@property (strong) AVPlayer *player;

@property (strong) AVPlayerLayer *playerLayer;
@property (weak) IBOutlet NSView *playerView;
@property (weak) IBOutlet NSView * dashView;




@property (weak,nonatomic) MacWindow * window;


// video preloads
@property (strong) AVPlayerItem * video1;
@property (strong) AVPlayerItem * video2;
@property (strong) AVPlayerItem * video3;
@property (strong) AVPlayerItem * video4;
@property (strong) AVPlayerItem * video5;

@property (assign, nonatomic) BOOL isVideoLoaded;


// timer
@property (strong, nonatomic) NSTimer * timer;
@property (strong, nonatomic) NSTimer * endTimer;


@property (strong, nonatomic) id loopObserver;
@property (assign, nonatomic) BOOL isLooping;
@end
