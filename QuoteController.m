//
//  QuoteController.m
//  Forismac
//
//  Created by Sergey Zenchenko on 10.10.09.
//  Copyright 2009 JAMG. All rights reserved.
//

#import "QuoteController.h"

@implementation QuoteController
@synthesize quote,author;
- (id)init {
	if (self=[super initWithWindowNibName:@"Quote"]) {
		
	}
	return self;
}
-(IBAction)sendMail:(id)sender {
	NSString *encodedSubject = [NSString stringWithFormat:@"SUBJECT=%@", [author stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSString *encodedBody = [NSString stringWithFormat:@"BODY=%@", [quote stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSString *encodedURLString = [NSString stringWithFormat:@"mailto:?%@&%@", encodedSubject, encodedBody];
	NSURL *mailtoURL = [NSURL URLWithString:encodedURLString];
	[[NSWorkspace sharedWorkspace] openURL:mailtoURL];
}
@end
