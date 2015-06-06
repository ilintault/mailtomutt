//
//  MailToMuttCommand.m
//  MailtoMutt
//
//  Created by Ian Lintault on 6/4/15.
//
//

#import "MailToMuttCommand.h"
#import "URLHandler.h"

@implementation MailToMuttCommand

-(id)performDefaultImplementation {

    // get the arguments
    NSDictionary *args = [self evaluatedArguments];
    
    NSString *stringToSearch = @"";
    
    if(args.count) {
        stringToSearch = [args valueForKey:@""];    // get the direct argument
    } else {
        // raise error
        [self setScriptErrorNumber:-50];
        [self setScriptErrorString:@"Parameter Error: A Parameter is expect for mailto."];
    }
    
    [super suspendExecution];
    
    NSDebug(@"MailTo String:\n%@", stringToSearch);
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:stringToSearch forKey:@"url"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"getURL" object:nil userInfo:userInfo];
    
    //[URLHandler handleEventString:stringToSearch];
    
    [super resumeExecutionWithResult:nil];
    
    return nil;
}

@end