//
//  ForismacAppDelegate.m
//  Forismac
//
//  Created by Sergey Zenchenko on 08.10.09.
//  Copyright 2009 JAMG. All rights reserved.
//

#import "ForismacAppDelegate.h"

@implementation ForismacAppDelegate

@synthesize settings,menu,statusItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

}
- (void) awakeFromNib {
	[settings close];
	statusItem = [[[NSStatusBar systemStatusBar] 
				   statusItemWithLength:NSVariableStatusItemLength]
				  retain];
	[statusItem setHighlightMode:YES];
	[statusItem setImage:[NSImage imageNamed:@"forismatic.png"]];
	[statusItem setEnabled:YES];
	[statusItem setToolTip:@"Forismac"];
	[statusItem setAction:@selector(showMenu:)];
	[statusItem setTarget:self];
	[statusItem setMenu:menu];
	NSURL *url=[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"forismatic" ofType:@"png"]];
	icon=[[NSData alloc] initWithContentsOfURL:url];
	[GrowlApplicationBridge setGrowlDelegate:self];
	
}
-(IBAction)exitApp:(id)sender {
	exit(0);
}
-(IBAction)snowSettings:(id)sender {
	[settings makeKeyAndOrderFront:sender];
}
-(void)showQuote:(NSString*)quote Author:(NSString*)author {
	[GrowlApplicationBridge
	 notifyWithTitle:author
	 description:quote
	 notificationName:@"New Quote"
	 iconData:icon
	 priority:0
	 isSticky:NO
	 clickContext:nil];
}
-(IBAction)updateQuotes:(id)sender {
	[self showQuote:@"qwdqwqwd" Author:@"zen"];
}

- (void)growlNotificationWasClicked:(id)clickContext {
	NSLog(@"Clicked on %@", clickContext);
}
-(void)dealloc {
	[icon release];
	[super dealloc];
}
@end
