//
//  SettingsController.m
//  Forismac
//
//  Created by Sergey Zenchenko on 10.10.09.
//  Copyright 2009 JAMG. All rights reserved.
//

#import "SettingsController.h"


@implementation SettingsController
@synthesize updateInterval;
- (id)init {
	if (self=[super initWithWindowNibName:@"Settings"]) {
		
	}
	return self;
}
@end
