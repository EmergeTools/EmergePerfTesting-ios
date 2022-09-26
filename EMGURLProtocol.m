//
//  EMGURLProtocol.m
//  PerfTesting
//
//  Created by Noah Martin on 8/4/22.
//

#import "EMGURLProtocol.h"
#import "EMGLog.h"

@implementation EMGURLProtocol

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task {
    return [self canInitWithRequest:task.originalRequest];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:@"EMGURLProtocolHandledKey" inRequest:request]) {
      return NO;
    }
    if ([request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"http"]) {
      return YES;
    } else {
        EMGLog(@"Not handling request URL = %@", request.URL.absoluteString);
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

+ (NSString *)folderNameForURL:(NSURL *)url {
  if (url.path.length > 0) {
    return [url.host stringByAppendingPathComponent:url.path];
  }
  return url.host;
}

dispatch_queue_t requestQueue(void) {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
        queue = dispatch_queue_create("com.emerge.networkreplay.requestQueue", attr);
    });
    return queue;
}

- (void)startLoading {
  dispatch_async(requestQueue(), ^{
    [self startLoading_Locked];
  });
}

- (NSURL *)directoryForURL:(NSURL *)url {
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSURL *emergeDirectoryURL = [documentsURL URLByAppendingPathComponent:@"emerge-cache"];
    return [emergeDirectoryURL URLByAppendingPathComponent:[EMGURLProtocol folderNameForURL:url]];
}

- (void)receivedResponse:(NSURLResponse *)response toRequest:(NSURLRequest *) request withData:(NSData *)data error:(NSError *)error {
    NSURL *emergeDirectoryURL = [self directoryForURL:request.URL];
    NSString *uuid = [NSUUID UUID].UUIDString;
    NSURL *requestURL = [emergeDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-request", uuid]];
    NSError *err = nil;
    NSData *requestData = [NSKeyedArchiver archivedDataWithRootObject:request requiringSecureCoding:YES error:&err];
    if (err) {
        EMGLog(@"Error archiving request %@", err);
        return;
    }
    if (![requestData writeToURL:requestURL atomically:YES]) {
        EMGLog(@"Error writing request to file");
    }
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        NSURL *responseURL = [emergeDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-response", uuid]];
        NSData *responseData = [NSKeyedArchiver archivedDataWithRootObject:response requiringSecureCoding:YES error:&err];
        if (err) {
            EMGLog(@"Error archiving response %@", err);
            return;
        }
        if (![responseData writeToURL:responseURL atomically:YES]) {
            EMGLog(@"Error writing resopnse to file");
        }
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        if (data) {
            NSURL *dataURL = [emergeDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-data", uuid]];
            if (![data writeToURL:dataURL atomically:YES]) {
                EMGLog(@"Error writing data to file");
            }
            [self.client URLProtocol:self didLoadData:data];
        }
    }
    [self.client URLProtocolDidFinishLoading:self];
    EMGLog(@"Finished url request %@", request);
}

+ (NSString *)comparisonStringForQueryParams:(NSURL *)url {
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];

    // Sort these to make sure the path is always the same
    NSArray *items = [components.queryItems sortedArrayUsingComparator:^NSComparisonResult(NSURLQueryItem *obj1, NSURLQueryItem *obj2) {
        return [obj2.name compare:obj1.name];
    }];
    NSString *string = @"";
    for (NSURLQueryItem *item in items) {
        // Workaround for Airbnb until they don't have a random string in this param
        if (![item.name isEqual:@"variables"] && ![item.name isEqual:@"extensions"]) {
            string = [string stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", item.name, item.value]];
        }
    }
    return string;
}

+ (BOOL)isRequestEqual:(NSURLRequest *)req1 to:(NSURLRequest *)req2 {
    if (req1.HTTPBody && req2.HTTPBody) {
        if (![req1.HTTPBody isEqualToData:req2.HTTPBody]) {
            return false;
        }
    } else if (req1.HTTPBody || req2.HTTPBody) {
        return false;
    }
    if (req1.allHTTPHeaderFields && req2.allHTTPHeaderFields) {
        if (![req1.allHTTPHeaderFields isEqual:req2.allHTTPHeaderFields]) {
            return false;
        }
    } else if (req1.allHTTPHeaderFields || req2.allHTTPHeaderFields) {
        return false;
    }

    NSString *comparisonString1 = [self comparisonStringForQueryParams:req1.URL];
    NSString *comparisonString2 = [self comparisonStringForQueryParams:req2.URL];

    return [req1.HTTPMethod isEqual:req2.HTTPMethod] &&
        [req1.URL.host isEqual:req2.URL.host] &&
        [req1.URL.path isEqual:req2.URL.path] &&
        [comparisonString1 isEqualToString:comparisonString2];
}

// Always called on requestQueue
- (void)startLoading_Locked {
    NSURL *url = self.request.URL;

    NSURL *emergeDirectoryURL = [self directoryForURL:url];
    if (![[NSFileManager defaultManager] fileExistsAtPath:emergeDirectoryURL.path isDirectory:NULL]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:emergeDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSURLRequest *matchedRequest = nil;
    NSURLResponse *matchedResponse = nil;
    NSData *matchedData = nil;
    NSArray<NSURL *> *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:emergeDirectoryURL includingPropertiesForKeys:nil options:0 error:nil];
    // This might be too slow - it has to read and decode potentially every saved request for this host/path
    // However, most of the time apps won't have many request with the same host/path
    for (NSURL *url in contents) {
        // Find the matching request if there is one
        NSMutableArray *components = [[url.pathComponents.lastObject componentsSeparatedByString:@"-"] mutableCopy];
        NSString *type = components.lastObject;
        [components removeLastObject];
        NSString *uuid = [components componentsJoinedByString:@"-"];
        if ([type isEqualToString:@"request"]) {
            NSData *data = [NSData dataWithContentsOfURL:url];
            NSError *error;
            NSURLRequest *request = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSURLRequest class] fromData:data error:&error];
            if (error) {
                EMGLog(@"Error unarchiving request %@", error);
            } else if ([EMGURLProtocol isRequestEqual:request to:self.request]) {
                NSURL *responseURL = [[url URLByDeletingLastPathComponent] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-response", uuid]];
                NSURL *dataURL = [[url URLByDeletingLastPathComponent] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-data", uuid]];
                matchedResponse = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSURLResponse class] fromData:[NSData dataWithContentsOfURL:responseURL] error: &error];
                if (error) {
                    EMGLog(@"Error unarchiving response %@", error);
                } else {
                  matchedData = [NSData dataWithContentsOfURL:dataURL];
                  matchedRequest = request;
                }
            }
            break;
        }
    }
    
    // If there is a matchedRequest, always return the saved response
    if (matchedRequest) {
        EMGLog(@"Found matching request for %@", self.request);
        if (matchedResponse) {
            [self.client URLProtocol:self didReceiveResponse:matchedResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            if (matchedData) {
                [self.client URLProtocol:self didLoadData:matchedData];
            }
        } else {
            // If we don't have a corresponding response there was an error loading this request. For now we don't replay errors and always respond
            // with a generic error.
            [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil]];
        }
        [self.client URLProtocolDidFinishLoading:self];
    } else if ([[NSProcessInfo processInfo].environment[@"EMG_RECORD_NETWORK"] isEqual:@"1"]) {
        EMGLog(@"Going to record for %@", self.request);
        // Only record, don't replay
        // TODO: Possibly implement an append only state when re-running with the control/experiment app
        NSMutableURLRequest *newRequest = [self.request mutableCopy];
        [NSURLProtocol setProperty:@YES forKey:@"EMGURLProtocolHandledKey" inRequest:newRequest];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                    dataTaskWithRequest:newRequest
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(requestQueue(), ^{
                [self receivedResponse:response toRequest:self.request withData:data error:error];
            });
        }];
        [task resume];
    } else {
        EMGLog(@"Did not finding matching request for %@", self.request);
        // Not recording but no recorded response, leave request hanging
    }
}

- (void)stopLoading { }



@end
