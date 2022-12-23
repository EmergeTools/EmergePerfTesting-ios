//
//  EMGURLProtocol.h
//  PerfTesting
//
//  Created by Noah Martin on 8/4/22.
//

#import <Foundation/Foundation.h>
#import "EMGTuple.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGURLProtocol : NSURLProtocol

+ (NSError *)responseNotFoundErrorWithType:(NSString *)type
                                      cachedValue:(NSString *)cachedValue
                                givenValue:(NSString *)givenValue;

+ (NSArray <NSDictionary *> *)requestMisses;

+ (NSString *)folderNameForURL:(NSURL *)url;

+ (BOOL)isCachedRequestEqual:(NSURLRequest *)req1 to:(NSURLRequest *)req2 error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
