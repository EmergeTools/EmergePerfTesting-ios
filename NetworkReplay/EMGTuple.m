#import "EMGTuple.h"

@implementation EMGTuple

+ (EMGTuple *)tupleWith:(id)first and:(id)second
{
    EMGTuple *tuple = [EMGTuple new];
    tuple->_first = first;
    tuple->_second = second;
    return tuple;
}

@end
