//
//  AppDelegate.h
//  IPG_osx_video_usb
//
//  Created by Jason Dunne, Gene Han on 3/31/15.
//  Copyright (c) 2015 Limitless. All rights reserved.
//

#import "PTChannel.h"
#import <Cocoa/Cocoa.h>

static const NSTimeInterval PTAppReconnectDelay = 1.0;

@interface AppDelegate : NSObject <NSApplicationDelegate, PTChannelDelegate>


@property (readonly) NSNumber *connectedDeviceID;
@property (strong) PTChannel *connectedChannel;


@end

