#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMGTuple<FirstType, SecondType> : NSObject

@property (strong, nonatomic, readonly) FirstType first;
@property (strong, nonatomic, readonly) SecondType second;

+ (EMGTuple *)tupleWith:(FirstType)first and:(SecondType)second;

@end

NS_ASSUME_NONNULL_END
