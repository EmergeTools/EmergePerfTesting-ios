#import <Foundation/Foundation.h>
#import "EMGLog.h"

void EMGLog(NSString *format, ...) {
    static dispatch_once_t queueCreationGuard;
    static NSUUID *uuid;
    dispatch_once(&queueCreationGuard, ^{
        uuid = [NSUUID new];
    });
    
    va_list args;
    va_start(args, format);
    NSString *input = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"### EMG %@ %@", uuid, input);
}
