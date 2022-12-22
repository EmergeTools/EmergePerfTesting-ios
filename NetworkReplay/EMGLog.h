#ifndef EMGLog_h
#define EMGLog_h

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

void EMGLog(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);

#ifdef __cplusplus
}
#endif


#endif /* EMGLog_h */
