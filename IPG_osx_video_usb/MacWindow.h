//
//  MacWindow.h
//  IPG_osx_ios
//
//  Created by Jason Dunne, Gene Han on 4/1/15.
//  Copyright (c) 2015 Limitless. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MacWindow : NSWindow<NSWindowDelegate>

@property (strong) id<NSWindowDelegate> windowDelegate;

@end
