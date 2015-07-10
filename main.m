
#import <Cocoa/Cocoa.h>
#import "URLHandler.h"

int main(int argc, const char *argv[])
{
    int retval;
    
    NSLog(@"Main start\n");
    
    URLHandler *urlhandler = [[URLHandler alloc] init];
    
    retval =  NSApplicationMain(argc, argv);
        
    [urlhandler release];
    
    NSLog(@"Main end\n");
    
    return retval;
}

