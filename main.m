
#import <Cocoa/Cocoa.h>
#import "URLHandler.h"

int main(int argc, const char *argv[])
{
    int retval;
    @autoreleasepool {
        URLHandler *urlhandler = [[URLHandler alloc] init];
        
        retval =  NSApplicationMain(argc, argv);
        
        [urlhandler release];
    }
    
    return retval;
}

