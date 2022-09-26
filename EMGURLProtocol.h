//
//  EMGURLProtocol.h
//  PerfTesting
//
//  Created by Noah Martin on 8/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMGURLProtocol : NSURLProtocol

+ (NSString *)folderNameForURL:(NSURL *)url;

+ (BOOL)isRequestEqual:(NSURLRequest *)req1 to:(NSURLRequest *)req2;

@end

NS_ASSUME_NONNULL_END
