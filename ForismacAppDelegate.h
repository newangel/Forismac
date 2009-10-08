//
//  ForismacAppDelegate.h
//  Forismac
//
//  Created by Sergey Zenchenko on 08.10.09.
//  Copyright 2009 JAMG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
@interface ForismacAppDelegate : NSObject <NSApplicationDelegate> {
    NSPanel *settings;
	NSMenu *menu;
	NSStatusItem *statusItem;
}

@property (assign) IBOutlet NSPanel *settings;
@property(assign) IBOutlet NSMenu *menu;
@property(retain) NSStatusItem *statusItem;
-(IBAction)exitApp:(id)sender;
-(IBAction)snowSettings:(id)sender;
@end
