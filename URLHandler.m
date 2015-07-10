#import <Cocoa/Cocoa.h>

#import "URLHandler.h"
#import "NSStringExt.h"
#import "Mutt.h"

@implementation URLHandler {
    BOOL _initialize;
}

- (id) init
{
    self = [super init];
    if (!self) return nil;
    
    _initialize = YES;
    return self;
}

- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
    NSLog(@"-URLHandler:dealloc");
}


- (void)awakeFromNib
{
    @synchronized(self) {
        if (_initialize ) {
            _initialize = NO;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(receiveURLNotification:)
                                                         name:@"getURL"
                                                       object:nil];
            
            NSLog(@"Registered for notification center event");
            
            
            [[ NSAppleEventManager sharedAppleEventManager ]
             setEventHandler: self
             andSelector: @selector(getUrl:)
             forEventClass: kInternetEventClass
             andEventID: kAEGetURL ];
            NSLog(@"Registered for apple event");
        }
    }
}


// receives the apple event for AppleScript
- (void) receiveURLNotification:(NSNotification *) notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString *urlString = [userInfo objectForKey:@"url"];
    [NSThread detachNewThreadSelector:@selector(handleEventString:) toTarget:self withObject:urlString];
}

// handles mailto: event
- (void)getUrl:(NSAppleEventDescriptor *)event
{
   NSString *urlString = [[event paramDescriptorForKeyword:'----'] stringValue ];
   [NSThread detachNewThreadSelector:@selector(handleEventString:) toTarget:self withObject:urlString];
}

// handle the event string and parse it
- (void)handleEventString:(NSString *)urlString
{
    NSDebug(@"Thread <<%@>>",[NSThread currentThread] );
    NSDebug(@"GetURL apple event received with <<%@>>", urlString);
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // Top-level pool
    
    Mutt *mutt = [[[Mutt alloc] init] autorelease];
    
    NSURL *url = [ NSURL URLWithString:urlString]; // get the URL delivered by the apple event
        
    if (url == nil){ // if NSURL did not eat it, then we give up
         NSLog(@"couldn't parse URL");
         return;
       }
    
    NSLog(@"URL successfully parsed");
      
	NSArray *parts = [[url resourceSpecifier] componentsSeparatedByString:@"?" ]; // get an address, and a query string
	
    NSMutableDictionary *paramDict = [ NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"to",@"",@"subject",@"",@"cc",@"",@"bcc",@"",@"body",@"",@"attachment-url",nil ];
    
    NSString *email = [ [ parts objectAtIndex:0 ] urlDecode ];  // this is the email part of the URL
    
    [paramDict setValue:email forKey:@"to"];

	if ([ parts count ] > 1) // more than one part
    {
		NSLog(@"there are %lu parts of the URL to check, %@.", (unsigned long)[ parts count ], ([ parts count ] > 2 ? @"but there should only be 1 or 2" : @"which is good"));
		
        NSArray *params = [ [ parts objectAtIndex:1 ] componentsSeparatedByString:@"&" ]; // split into param=value pairs
        
		NSLog(@"There are %lu parameters (key=value) in the second part of the URL (the query string)", (unsigned long)[ params count ]);
        
		NSEnumerator *cursor = [ params objectEnumerator ];
	
		id string; // points to an object, a param=value pair in this case, by walking params
	
		/* very cheap query param "parsing" */
        
		while(string = [ cursor nextObject ]) {
		
            NSArray *kvp = [ string componentsSeparatedByString:@"=" ]; // seperate into key and value
			
            if ([ kvp count ] != 2){  // we dont have enough values
				NSDebug(@"KVP count is %d!=2. Doesn't look like a valid query string part.", [ kvp count] );
				continue;
			}
            
			NSString *key = [[ kvp objectAtIndex:0 ] lowercaseString]; // this shuts up the warnings - i still don't know how to cast an object like [ (NSString *)[ kvp objectAtIndex: 0 ] compare:@"subject" ]
			
            NSDebug(@"param %@ found in URL, with value %@", key, [[ kvp objectAtIndex:1 ] urlDecode ]);
            
            if (![ key compare:@"subject" ] || ![ key compare:@"body" ] || ![ key compare:@"cc" ] || ![key compare:@"bcc"] || ![key compare:@"attachment-url"] || ![key compare:@"send-now"])
                // these items are what we want to support
                [ paramDict setValue:[[ kvp objectAtIndex:1 ] urlDecode ] forKey:key ]; // urlDecode was stolen from iJournal
		}
	}

    NSDebug(@"To: '%@' CC: '%@' BCC: '%@' Attachment-url: '%@' Subject: '%@' and Body:\n<<EOF\n%@\nEOF", email, [paramDict valueForKey:@"cc"],[paramDict valueForKey:@"cc"], [paramDict valueForKey:@"attachment-url"],[paramDict valueForKey:@"subject" ], [ paramDict valueForKey:@"body" ]);
	
    [mutt setMessageFromDict:paramDict];
    [mutt printMessage];
    [mutt newMessageString];
   
    [pool release];  // Release the objects in the pool.
    
    NSLog(@"Bottom of handleEventString\n");
}
@end

