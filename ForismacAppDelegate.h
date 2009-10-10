//
//  ForismacAppDelegate.h
//  Forismac
//
//  Created by Sergey Zenchenko on 08.10.09.
//  Copyright 2009 JAMG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl-WithInstaller/Growl.h>
@class SettingsController;
#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
	@interface ForismacAppDelegate : NSObject <GrowlApplicationBridgeDelegate>
#else
	@interface ForismacAppDelegate : NSObject <NSApplicationDelegate,GrowlApplicationBridgeDelegate>
#endif 
{
	NSMenu *menu;
	NSStatusItem *statusItem;
	NSData *icon;
	int update_time;
	NSTimer *timer;
	NSMutableData *responseData;
	NSURL *baseURL;
	NSMenuItem *toogleAutoUpdateItem;
	SettingsController *settingsController;
}
@property(assign) IBOutlet NSMenu *menu;
@property(retain) NSStatusItem *statusItem;
@property(retain) NSData *icon;
@property(retain) NSTimer *timer;
@property(retain) IBOutlet NSMenuItem *toogleAutoUpdateItem;
@property(retain) SettingsController *settingsController;
-(IBAction)exitApp:(id)sender;
-(IBAction)snowSettings:(id)sender;
-(IBAction)updateQuotes:(id)sender;
-(IBAction)toogleAutoupdate:(id)sender;
@end
