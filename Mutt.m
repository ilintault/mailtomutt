#import "NSStringExt.h"
#import "Mutt.h"

#include <string.h>
#include <unistd.h>

@implementation Mutt
    @synthesize to = _to;
    @synthesize cc = _cc;
    @synthesize bcc = _bcc;
    @synthesize subject = _subject;
    @synthesize attachment_url = _attachment_url;
    @synthesize body = _body;
    BOOL _can_send_now;
    BOOL _has_attachment;

#pragma mark - Init & Dealloc methods

- (id)init
{
    if (self = [super init]) {
        // Initialize any properties or setup code here
    }
    _has_attachment = NO;
    _can_send_now = NO;
    
    return self;
}

// Dealloc method should always follow init method
- (void)dealloc
{
    // Remove any observers or free any necessary cache, etc.
    [super dealloc];
}

- (void) setTo:(NSString *)to {
    _to = to;
}

- (void) setCc:(NSString *)cc {
    _cc = cc;
}

- (void) setBcc:(NSString *)bcc {
    _bcc = bcc;
}

- (void) setSubject:(NSString *)subject {
    _subject = subject;
}

- (void) setAttachment_url:(NSString *)attachment_url {
    _attachment_url = attachment_url;
}

- (void) setBody:(NSString *)body {
    _body = body;
}

- (NSString*)to {
    return _to;
}

- (NSString*)cc {
    return _cc;
}


- (NSString*)bcc {
    return _bcc;
}

- (NSString*)subject {
    return _subject;
}

- (NSString*)attachment_url {
    return _attachment_url;
}

- (NSString*)body {
    return _body;
}

/* opens mutt with a file */

- (void) newMessageFromFile:(NSString *)path
{
	NSDebug(@"Opening mutt with file %@", path);

    NSMutableString *mutt_command = [NSMutableString stringWithString:@"mutt "];
    
    if (_can_send_now)
    {
        [mutt_command appendFormat:@"'%@' ",self.to];
        if ([self.cc length]>0)
            [mutt_command appendFormat:@"-c '%@' ",self.cc];
        if ([self.bcc length]>0)
            [mutt_command appendFormat:@"-b '%@' ",self.bcc];
        [mutt_command appendFormat:@"-s '%@' ",self.subject];
    }

    if (!_can_send_now)
    {
        [mutt_command appendFormat:@"-H '%@'",path];
    }
    
    if (_has_attachment)
    {
        [mutt_command appendString:@" -a '"];
        [mutt_command appendString:self.attachment_url];
        [mutt_command appendString:@"'"];
    }
    
    if (_can_send_now)
    {
        
        [mutt_command appendFormat:@" < '%@'",path];
    }
    
    NSLog(@"mutt_command: %@",mutt_command);
    
    // Old Iterm
	//NSString *source = [ NSString stringWithFormat:@"tell application \"/Applications/iTerm2.app\"\nmake new terminal\ntell the current terminal\nactivate current session\nlaunch session \"Default Session\"\ntell the last session\nwrite text \"%@\"\nend tell\nend tell\nend tell\n", mutt_command ];

    // New Iterm2  tell current window
    NSString *source = [ NSString stringWithFormat:@"tell application \"/Applications/iTerm.app\"\nactivate\ntell current window\ncreate tab with profile \"Default\"\ntell current session\nwrite text \"%@\"\nend tell\nend tell\nend tell\n", mutt_command];
   
	/* create the NSAppleScript object with the source */
    
	/* create a dictionary in which the execution will store it's errors */
	NSMutableDictionary *error = [ NSMutableDictionary dictionary ];

    NSAppleScript *task = [[[NSAppleScript alloc] initWithSource:source ] autorelease];

//    NSDebug(@"The compiled script is \n<<EOF\n%@\nEOF", [ task script : source ]);
    
    [task executeAndReturnError:&error];
    
    if (task == nil)
    {
        NSLog(@"%s AppleScript task error = %@", __PRETTY_FUNCTION__, error);
    }
    else
        NSLog(@"Script executed OK");
    
    //[task release];
    
	/* execute */
}

/* makes a temp file */

- (void) newMessageWithContent:(NSString *)content
{
	NSDebug(@"creating message with content\n<<EOF\n%@\nEOF", content);

	/* use the mktemp(3) family of functions (standard C library) to create a temporary file, openned atomically in the users home directory */
	/* mkstemp takes a template - it replaces the XX part at the end with random stuff, and then opens the file safely, that is only if it doesn't exist */
	/* we first build a format, which should be like /tmp/501/Temporary\ Items/MailtoMutt-XXXXXXXX, and then get the cString out of it */
	/* the following code section leaves us with template, a c string which we have to dispose of */

	//warning UTF8String created - we might prefer ASCII. How do we do it cleanly? NSString has got a notion of a default encoding (user preferences setting), which affects the cString methods
    
	NSLog(@"Preparing UTF8 string");
    
	const char *constTemplate = [ [ NSString stringWithFormat:@"%@/MailtoMutt-XXXXXXXX", NSTemporaryDirectory() ] UTF8String ]; /* create the filename. It's constant, so we have to copy it */
    
	NSLog(@"Determining length of constTemplate");
	
    size_t templateLength = (strlen(constTemplate) + 1) * sizeof(char); /* the length of the string, plus the null byte */
	
    NSDebug(@"created template %s with length %d", constTemplate, templateLength);

	char *template;
    
	// warning malloc fail will not raise exception but simply return
	if ((template = (char *)malloc(templateLength)) == NULL){ /* malloc this length */
		NSLog(@"Malloc failed");
		return; // should raise NSException instead
	}

	(void)strlcpy(template, constTemplate, templateLength); /* copy the string to a non const one. beh. */
	NSLog(@"copied string");
    
	int fd = mkstemp(template); /* make the template */
	NSDebug(@"mkstmp created <<%s>>", template);

	/* create a filehandle out of the filedescriptor that mkstemp gave us */
	NSFileHandle *fh = [ [ [ NSFileHandle alloc ] initWithFileDescriptor:fd ] autorelease ];
	
	
	NSDebug(@"Writing message:\n<<EOF\n%@\nEOF", content);
    
	[ fh writeData:[ content dataUsingEncoding:NSUTF8StringEncoding ] ]; /* write the contents into the file */
	[ fh closeFile ]; /* finished writing */

		
	/* use the temp file to create a mutt message */
	[ self  newMessageFromFile:[ NSString stringWithUTF8String:template ] ];
	
	NSLog(@"deleting temp file");
    //	warning zombie files left in temp dir, cant find logical way to clean up
	/* unlink(template); don't delete the file - mutt probably hasn't openned it. If we can monitor vnode /access/, maybe this can be solved */
	free(template); /* deallocate the template string */
    
    //[NSApp terminate:nil];
}

- (void) setMessageFromDict:(NSMutableDictionary *)dict // create a message from dict pairs
{
    NSLog(@"Inside setMessageFromDict\n");
    NSLog(@"%@\n",dict);
    
    self.to = [dict objectForKey:@"to"];
    self.cc = [dict objectForKey:@"cc"];
    self.bcc = [dict objectForKey:@"bcc"];
    self.subject = [dict objectForKey:@"subject"];
    self.attachment_url = [dict objectForKey:@"attachment-url"];
    self.body = [dict objectForKey:@"body"];
    
    if([self.attachment_url length] > 0)
        _has_attachment = YES;
    
    if([[dict objectForKey:@"send-now"] length]>0)
        _can_send_now = YES;
}

-(void) printMessage
{
    NSLog(@"Inside printMessage\n");
    NSLog(@"%@\n",self.to);
    NSLog(@"%@\n",self.cc);
    NSLog(@"%@\n",self.bcc);
    NSLog(@"%@\n",self.subject);
    NSLog(@"%@\n",self.attachment_url);
    NSLog(@"%@\n",self.body);
    
    if (_can_send_now)
        NSLog(@"----------- Send it now\n");
}

/* concatenates content to message */

- (void) newMessageString
{
    NSString * message;
    
    if (_can_send_now)
    {
        message = [NSString stringWithFormat:@"\n%@\n",self.body  ];
    }
        else
        {
           message = [NSString stringWithFormat:@"To: %@\nCc: %@\nBcc: %@\nSubject: %@\n\n%@",
                          [self.to headerEscape],
                          [self.cc headerEscape],
                          [self.bcc headerEscape],
                          [self.subject headerEscape],
                          self.body  ];
        }
    
    [ self newMessageWithContent:message ];
}

@end
