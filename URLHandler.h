#import <Foundation/Foundation.h>
#include "Mutt.h"

@interface URLHandler : NSObject

- (void)getUrl:(NSAppleEventDescriptor *)event;                // handles the GetURL event from mailto:
- (void)handleEventString:(NSString *)urlString;
- (void)receiveURLNotification:(NSNotification *) notification;  // handles the event from applescript

@end
