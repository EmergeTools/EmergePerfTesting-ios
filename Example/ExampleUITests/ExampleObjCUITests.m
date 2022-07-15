#import <XCTest/XCTest.h>
#import <EMGPerfTesting/EMGPerfTesting-Swift.h>

@interface ObjcPerfTest : NSObject <EMGPerfTest>

@end

@implementation ObjcPerfTest

- (void)runInitialSetupWithApp:(XCUIApplication *)app
{
    NSLog(@"objc setup");
}

- (void)runIterationWithApp:(XCUIApplication *)app
{
    NSLog(@"objc iteration");
}

@end

@interface ExampleObjCUITests : XCTestCase

@end

@implementation ExampleObjCUITests

- (void)testPerfTests
{
    [PerfTestRunner runAllPerfTestsForBundleOfClass:[self class]];
}

@end
