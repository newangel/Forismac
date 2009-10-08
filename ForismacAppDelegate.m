//
//  ForismacAppDelegate.m
//  Forismac
//
//  Created by Sergey Zenchenko on 08.10.09.
//  Copyright 2009 JAMG. All rights reserved.
//

#import "ForismacAppDelegate.h"

@implementation ForismacAppDelegate

@synthesize settings,menu,statusItem,icon,timer;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

}
- (void) awakeFromNib {
	[settings close];
	//NSUserDefaults *defs=[[NSUserDefaults alloc] init];
	//update_time=[[defs valueForKey:@"update_time"] intValue];
	//timer = [NSTimer scheduledTimerWithTimeInterval:update_time target:self selector:@selector(newQuote:) userInfo:nil repeats:YES];
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
	responseData = [[NSMutableData data] retain];
	baseURL = [[NSURL URLWithString:@"http://www.forismatic.com/api/1.0/"] retain];
	
	NSURL *url=[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"forismatic" ofType:@"png"]];
	icon=[[NSData alloc] initWithContentsOfURL:url];
	[GrowlApplicationBridge setGrowlDelegate:self];
	
}
-(void)newQuote:(id)sender {
	[self loadQuote];
}
-(IBAction)toogleAutoupdate:(id)sender {
	if(timer) {
		[timer invalidate];
		[toogleAutoUpdateItem setTitle:@"Старт автоапдейт"];
		[toogleAutoUpdateItem setState:2];
	} else {
		[timer release];
		timer = [NSTimer scheduledTimerWithTimeInterval:update_time target:self selector:@selector(newQuote:) userInfo:nil repeats:YES];
		[toogleAutoUpdateItem setTitle:@"Стоп автоапдейт"];
		[toogleAutoUpdateItem setState:1];
	}
}
-(IBAction)exitApp:(id)sender {
	exit(0);
}
-(IBAction)snowSettings:(id)sender {
	[NSBundle loadNibNamed:@"Settings.xib" owner:self];
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
	
	[requestBodyData appendData:boundaryData];
	[requestBodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: multipart/form-data; "] dataUsingEncoding:encoding]];
	[requestBodyData appendData:[[NSString stringWithFormat:@"name=\"%@\"; ", @"method"] dataUsingEncoding:encoding]];
	[requestBodyData appendData:[[NSString stringWithFormat:@"\r\n\r\n"] dataUsingEncoding:encoding]];
	[requestBodyData appendData:[[NSString stringWithFormat:@"getQuote"] dataUsingEncoding:encoding]];
	[requestBodyData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:encoding]];
	[requestBodyData appendData:boundaryData];
	
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
	NSString *xpathQueryStringText =@"//forismatic";
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
	[icon release];
	[super dealloc];
}
@end
