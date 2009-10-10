//
//  ForismacAppDelegate.m
//  Forismac
//
//  Created by Sergey Zenchenko on 08.10.09.
//  Copyright 2009 JAMG. All rights reserved.
//

#import "ForismacAppDelegate.h"

@implementation ForismacAppDelegate
@synthesize menu,
			statusItem,
			icon,
			timer,
			toogleAutoUpdateItem,
			settingsController,
			updateInterval;
- (void) awakeFromNib {
	statusItem = [[[NSStatusBar systemStatusBar] 
				   statusItemWithLength:NSVariableStatusItemLength]
				  retain];
	[statusItem setHighlightMode:YES];
	[statusItem setImage:[NSImage imageNamed:@"Forismac-24.png"]];
	[statusItem setAlternateImage:[NSImage imageNamed:@"Forismac-24i.png"]];
	[statusItem setEnabled:YES];
	[statusItem setToolTip:@"Forismac"];
	[statusItem setTarget:self];
	[statusItem setMenu:menu];
	updateInterval = [[NSUserDefaults standardUserDefaults] valueForKey:@"updateInterval"];
	if(!updateInterval) {
		updateInterval=[NSNumber numberWithInt:1];
		[[NSUserDefaults standardUserDefaults] setObject:updateInterval forKey:@"updateInterval"];
	}
	responseData=[[NSMutableData alloc] init];
	baseURL = [[NSURL URLWithString:@"http://www.forismatic.com/api/1.0/"] retain];
	timer = [NSTimer scheduledTimerWithTimeInterval:[updateInterval intValue] target:self selector:@selector(newQuote:) userInfo:nil repeats:YES];
	
	NSURL *url=[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"icon" ofType:@"png"]];
	icon=[[NSData alloc] initWithContentsOfURL:url];
	[GrowlApplicationBridge setGrowlDelegate:self];
	[self addObserver:self forKeyPath:@"self.updateInterval" options:0 context:nil];
	
}
-(void)newQuote:(id)sender {
	[self loadQuote];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"self.updateInterval"]) {
		[timer invalidate];
		timer = nil;
		timer = [NSTimer scheduledTimerWithTimeInterval:[updateInterval intValue] target:self selector:@selector(newQuote:) userInfo:nil repeats:YES];
		updateInterval=[NSNumber numberWithInt:1];[[NSUserDefaults standardUserDefaults] setObject:updateInterval forKey:@"updateInterval"];
	}
}
-(IBAction)toogleAutoupdate:(id)sender {
	if(timer) {
		[timer invalidate];
		timer = nil;
		[toogleAutoUpdateItem setTitle:@"Старт автоапдейт"];
	} else {
		timer = [NSTimer scheduledTimerWithTimeInterval:[updateInterval intValue] target:self selector:@selector(newQuote:) userInfo:nil repeats:YES];
		[toogleAutoUpdateItem setTitle:@"Стоп автоапдейт"];
	}
}
-(IBAction)exitApp:(id)sender {
	exit(0);
}
-(IBAction)snowSettings:(id)sender {
    if (!settingsController) {
		settingsController = [[SettingsController alloc] init];
		[settingsController setUpdateInterval:updateInterval];
		[self bind:@"updateInterval" toObject:settingsController withKeyPath:@"updateInterval" options:0];
    }
    [settingsController showWindow:self];
}
-(void)showQuote:(NSString*)quote Author:(NSString*)author {
	NSDictionary *context=[NSDictionary dictionaryWithObjectsAndKeys:quote,@"quote",author,@"author",nil];
	[GrowlApplicationBridge
	 notifyWithTitle:author
	 description:quote
	 notificationName:@"New Quote"
	 iconData:icon
	 priority:0
	 isSticky:NO
	 clickContext:context];
}
-(IBAction)updateQuotes:(id)sender {
	[self loadQuote];
}
-(void)loadQuote {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
	[request setHTTPMethod:@"POST"];
	NSMutableData *requestBodyData = [NSMutableData data];
	NSStringEncoding encoding = NSUTF8StringEncoding;
	
	NSString *boundary = [NSString stringWithFormat:@"--%@--", [[NSProcessInfo processInfo] globallyUniqueString]];
	[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	NSData *boundaryData = [[[[@"--" stringByAppendingString:boundary] stringByAppendingString:@"\r\n"] dataUsingEncoding:encoding] retain];
	
	//Set method=getQuote post param
	[requestBodyData appendData:boundaryData];
	[requestBodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: multipart/form-data; "] dataUsingEncoding:encoding]];
	[requestBodyData appendData:[[NSString stringWithFormat:@"name=\"%@\"; ", @"method"] dataUsingEncoding:encoding]];
	[requestBodyData appendData:[[NSString stringWithFormat:@"\r\n\r\n"] dataUsingEncoding:encoding]];
	[requestBodyData appendData:[[NSString stringWithFormat:@"getQuote"] dataUsingEncoding:encoding]];
	[requestBodyData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:encoding]];
	[requestBodyData appendData:boundaryData];
	
	//Set format=xml post param
	[requestBodyData appendData:boundaryData];
	[requestBodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: multipart/form-data; "] dataUsingEncoding:encoding]];
	[requestBodyData appendData:[[NSString stringWithFormat:@"name=\"%@\"; ", @"format"] dataUsingEncoding:encoding]];
	[requestBodyData appendData:[[NSString stringWithFormat:@"\r\n\r\n"] dataUsingEncoding:encoding]];
	[requestBodyData appendData:[[NSString stringWithFormat:@"xml"] dataUsingEncoding:encoding]];
	[requestBodyData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:encoding]];
	[requestBodyData appendData:boundaryData];
	
	[request setHTTPBody:requestBodyData];
	
    NSURLConnection *con=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
- (void)growlNotificationWasClicked:(id)clickContext {
	QuoteController *quoteController=[[QuoteController alloc] init];
	[quoteController setQuote:[clickContext valueForKey:@"quote"]];
	[quoteController setAuthor:[clickContext valueForKey:@"author"]];
    [quoteController showWindow:self];
}
- (NSURLRequest *)connection:(NSURLConnection *)connection
			 willSendRequest:(NSURLRequest *)request
			redirectResponse:(NSURLResponse *)redirectResponse
{
    [baseURL autorelease];
    baseURL = [[request URL] retain];
    return request;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[NSAlert alertWithError:error] runModal];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSError *error;
	NSString *string = [[NSString alloc] initWithData:responseData 
											 encoding:NSUTF8StringEncoding];
	NSLog(@"%@",string);
	NSXMLDocument *document =[[NSXMLDocument alloc] initWithXMLString:string options:NSXMLDocumentTidyXML error:&error];
	
	NSXMLElement *rootNode = [document rootElement];
	NSString *xpathQueryStringText =@"//forismatic/quote/quoteText";
	NSArray *nodesText = [rootNode nodesForXPath:xpathQueryStringText error:&error];
	
	NSString *xpathQueryStringAuthor =@"//forismatic/quote/quoteAuthor";
	NSArray *nodesAuthor = [rootNode nodesForXPath:xpathQueryStringAuthor error:&error];
	
	if([nodesText count]>0) {
		NSString *text = [[[nodesText objectAtIndex:0] childAtIndex:0] stringValue];
		NSString *author = [[[nodesAuthor objectAtIndex:0] childAtIndex:0] stringValue];
		[self showQuote:text Author:author];
	}
}
-(void)dealloc {
	[super dealloc];
}
@end
