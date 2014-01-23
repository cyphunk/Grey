//
//  AppDelegate.m
//  Grey
//
//  Created by Nathan Fain on 05/07/2012.
//  No rights reserved. Do with it as you please.
//
//  To change hotkey (cmd+shift+c) look at the awakeFromNib() function.
//  To change the timeout (5 minutes) look at monoOff() function
//

#import "AppDelegate.h"
#include <ApplicationServices/ApplicationServices.h>



@implementation AppDelegate
@synthesize window = _window;

/* 
   Monochrome checkbox:
   monotoggle is attached to the checkbox in the UI Designer
 */
- (void) monoOn {
    NSLog(@"Monochrome on");
    CGDisplayForceToGray(true);      
    NSButton *box = monocheck;
    box.state = NSOnState;
}
- (void) monoOff {
    NSLog(@"Monochrome off");
    CGDisplayForceToGray(false);      
    NSButton *box = monocheck;
    box.state = NSOffState;
    // time it so that you can only be UNGRAY for N seconds
    [self performSelector:@selector(onTick:) withObject:nil afterDelay:5*60.0];
}
@synthesize monocheck;
- (IBAction)monotoggle:(id)sender {
    if ([monocheck state] == NSOnState)
        [self monoOn];
    else 
        [self monoOff];
}
// monochrome hotkey handler. attached in awakeFromNib()+myHotKeyHandler()
- (void) hotKeyMono {
    if ([monocheck state] == NSOnState) {
        [self monoOff];
    } else {
        [self monoOn];
    }
}
// used in monoOff to turn mono back on
-(void)onTick:(NSTimer *)timer {
    NSLog(@"Timeout Forcing Monochrome on");
    [self monoOn];
}

/* 
   Dropshadow checkbox:
   dropshadow is attached to the checkbox in the UI Designer
   "#define" values from:
   http://context-macosx.googlecode.com/svn/trunk/Tools/Utilities/Vector%20Grab/CGSDebug.h
 */
#define kCGSDebugOptionNormal 0
#define kCGSDebugOptionNoShadows 0x4000
@synthesize dropshadow;
- (IBAction)dropshadow:(id)sender {
    NSLog(@"Dropshadow toggle");
    CGSSetDebugOptions([dropshadow state] ? kCGSDebugOptionNoShadows : kCGSDebugOptionNormal);
}
/*
   Dock icon checkbox:
   Transforming the process from Not having a Dock icon to Having a dock icon
   is a one way process. The reverse does not exists. So, by default the application
   is off (Application is Agent option in plist) and you can turn it on with the
   checkbox.
   https://developer.apple.com/library/mac/#documentation/Carbon/Reference/Process_Manager/Reference/reference.html
 */
@synthesize nodockcheck;
- (IBAction)nodock:(id)sender {
    NSLog(@"Nodock toggle");
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    if ([nodockcheck state] == NSOffState) {
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
        [nodockcheck setEnabled:(false)]; // cant use after using once
    }    
}

// Application init
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Setup Default Shadow
    CGSSetDebugOptions(kCGSDebugOptionNoShadows);
    // Setup Default Monochrome
    CGDisplayForceToGray(true);
    
    // Setup Default Gamma. Not working really yet
    /*
	CGGetDisplayTransferByFormula (0,
                                    &redMin, &redMax, &redGamma,
                                    &greenMin, &greenMax, &greenGamma,
                                    &blueMin, &blueMax, &blueGamma);
    CGSetDisplayTransferByFormula (0,
                                    redMin,   redMax,   redGamma,
                                    greenMin, greenMax, greenGamma,
                                    blueMin,  blueMax,  blueGamma);		
     */

}
// Application UI init
// sets the hotkeys 
- (void)awakeFromNib {
    //Register the Hotkeys
    EventHotKeyRef gMyHotKeyRef = NULL;
    EventHotKeyID gMyHotKeyID;
    EventTypeSpec eventType;
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyReleased;
    // Monochrome hotkey:
    InstallApplicationEventHandler(&myHotKeyHandler,1,&eventType, (__bridge void *) self, NULL);
    gMyHotKeyID.signature='MONO';
    gMyHotKeyID.id=1;
    // key list in /System/Library/Frameworks/Carbon.framework//Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
    // 8 = "C"
    RegisterEventHotKey(8, cmdKey+shiftKey, gMyHotKeyID,
                        GetApplicationEventTarget(), 0, &gMyHotKeyRef);
}
// Application exit:
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    CGSSetDebugOptions(kCGSDebugOptionNormal);
    CGDisplayForceToGray(false);  
    CGDisplayRestoreColorSyncSettings();
}

/*
   Hotkey handler
 */
OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,
                         void *userData) {
    AppDelegate * mySelf = (__bridge AppDelegate *) userData;
    EventHotKeyID hkCom;
    GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,
                      sizeof(hkCom),NULL,&hkCom);
    int hotKeyID = hkCom.id;
    switch (hotKeyID) {
        case 1: //mono
            [mySelf hotKeyMono];
            break;
    }
    
    return CallNextEventHandler(nextHandler, theEvent);
    //return noErr;
}


@end


/* 

    NOTES

*/
// HOTKEY
// could use but then would need to enable accessibility options:
// http://blog.walkingsmarts.com/global-hotkeys-in-cocoa-on-snow-leopard/ (dont want)
// could diy http://stackoverflow.com/questions/4807319/register-hotkey (failed)
// could use lib https://github.com/jaz303/JFHotkeyManager
// Keycode refs: http://boredzo.org/blog/archives/2007-05-22/virtual-key-codes
//
// Used the JFHotkeyManager. Got a lot of ARC compile erros. Here is how i set it up:
//   Drag into code
//   In Grey/Build Sources, add the .m to the sources to compile (if not done during drag)
//   In the same place add the compile flag -fno-objc-arc for that .m, avoids LLVM ARC
// run
// 
// Bah its not working in lion, even the example project that came with JF
//
// Trying: http://stackoverflow.com/questions/10025051/cocoa-global-shortcuts-in-lion
//  To install http://stackoverflow.com/questions/1675307/best-way-to-install-a-custom-cocoa-framework
//   Deployment Location = YES (click the checkbox)
//   Installation Build Products Location = /
//   Installation Directory = /Library/Frameworks


