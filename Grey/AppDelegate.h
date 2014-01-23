//
//  AppDelegate.h
//  Grey
//
//  Created by Nathan Fain on 05/07/2012.
//  No rights reserved. Do with it as you please.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSButton *monocheck;
@property (assign) IBOutlet NSButton *dropshadow;
@property (assign) IBOutlet NSButton *nodockcheck;
//@property CGGammaValue redMin, redMax, redGamma,
//                       greenMin, greenMax, greenGamma,
//                       blueMin, blueMax, blueGamma;
@end
