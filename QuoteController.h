//
//  QuoteController.h
//  Forismac
//
//  Created by Sergey Zenchenko on 10.10.09.
//  Copyright 2009 JAMG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface QuoteController : NSWindowController {
	NSString *quote;
	NSString *author;
}
@property(retain) NSString *quote;
@property(retain) NSString *author;
-(IBAction)sendMail:(id)sender;
@end
