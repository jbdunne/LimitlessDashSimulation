//
//  MainViewController.h
//  IPG_osx_ios
//
//  Created by Gene Han on 5/10/15.
//  Copyright (c) 2015 ipg. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "config.h"

#import "TopUI.h"
#import "BotUI.h"

#import "HomeView.h"
#import "DiscoveryView.h"
#import "MusicView.h"
#import "PhoneView.h"

#import "PTChannel.h"

@interface MainViewController : UIViewController<BotUIDelegate, PTChannelDelegate>

// 0.0 TOP UI
@property (strong, nonatomic) TopUI * topUI;

// 0.1 BOT UI
@property (strong, nonatomic) BotUI * botUI;


// 1~4 Views
@property (strong, nonatomic) HomeView * homeView;
@property (strong, nonatomic) DiscoveryView * discView;
@property (strong, nonatomic) MusicView * musicView;
@property (strong, nonatomic) PhoneView * phoneView;
@property (strong, nonatomic) NSArray * viewArray;


// FUNCTIONS
- (void) initializeView;




// CONNECTION
- (void)appendOutputMessage:(NSString*)message;
- (void)sendDeviceInfo;

@property (strong,nonatomic) UILabel * ad;


@end
