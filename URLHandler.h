#import <Foundation/Foundation.h>
#include "Mutt.h"

@interface URLHandler : NSObject

//- (void)awakeFromNib;								// initial action, registers apple event
- (void)getUrl:(NSAppleEventDescriptor *)event;		// handles the GetURL event
- (void)handleEventString:(NSString *)urlString;
- (void)receiveURLNotification:(NSNotification *) notification;

@end
