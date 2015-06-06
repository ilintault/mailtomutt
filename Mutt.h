/* High-level abstraction of the mutt mailer
 * Implemented using AppleScripts and Terminal.app */


#import <Foundation/Foundation.h>

//#define NSDebugEnabled 1

@interface Mutt : NSObject

@property (nonatomic,retain) NSString* to;
@property (nonatomic,retain) NSString* cc;
@property (nonatomic,retain) NSString* bcc;
@property (nonatomic,retain) NSString* subject;
@property (nonatomic,retain) NSString* body;
@property (nonatomic,retain) NSString* attachment_url;

- (void)newMessageWithContent:(NSString *)content;												// create a message from a string, should be RFC822

- (void)newMessageFromFile:(NSString *)file;													// create a message from a file, should be RFC822

- (void)setMessageFromDict:(NSMutableDictionary *)dict;                                         // set the message parameters from a MutableDict

- (void) newMessageString;                                                                      // create a new Message String from the set params

- (void)printMessage;

@end