#import <XCTest/XCTest.h>
#import <EMGPerfTesting/EMGPerfTesting-Swift.h>

@interface ExampleObjCUITests : XCTestCase

@end

@implementation ExampleObjCUITests

- (void)testPerfTests
{
    [PerfTestRunner runAllPerfTestsForBundleOfClass:[self class]];
}

@end
