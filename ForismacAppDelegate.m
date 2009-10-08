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
}
-(IBAction)exitApp:(id)sender {
	exit(0);
}
-(IBAction)snowSettings:(id)sender {
	[settings makeKeyAndOrderFront:sender];
}
@end
