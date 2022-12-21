import UIKit
import XCTest

@objc public class PerfTestRunner: NSObject {
  
    @objc public static func runAllPerfTestsForBundle(ofClass classInBundle: AnyClass) {
        let imageName = class_getImageName(classInBundle)!
        var outCount: UInt32 = 0
        let classNames = objc_copyClassNamesForImage(imageName, &outCount)!
        for i in 0..<Int(outCount) {
            let className = classNames[i]
            let aClass = objc_getClass(className)
          
            if let perfTestClass = aClass as? EMGPerfTest.Type {
                let objcClass = perfTestClass as! NSObject.Type
                let test = objcClass.init() as! EMGPerfTest
                print("Testing perf test class \(String(describing: perfTestClass))")
                print("Running initial setup for \(String(describing: perfTestClass))")
                
                let setupApp = makeApplication(forTest: test)
                test.runInitialSetup(withApp: setupApp)
              
                print("Running two iterations for \(String(describing: perfTestClass))")
                for i in 0..<2 {
                    print("Iteration \(i + 1)")
                    let app = makeApplication(forTest: test)
                    test.runIteration(withApp: app)
                }
            }
        }
    }
    
    private static func makeApplication(forTest test: EMGPerfTest) -> XCUIApplication {
        let emergeLaunchEnvironment = [
            "DYLD_INSERT_LIBRARIES" : "PerfTesting", // TODO
            "EMERGE_CLEAR_DISK" : "1",
//            "EMERGE_CFBUNDLENAME": runnerContext.bundleName,
            "EMERGE_CLASS_NAME" : String(describing: test.self),
            "EMERGE_IS_PERFORMANCE_TESTING" : "1",
            "EMG_RECORD_NETWORK" : "1",
        ]
        let testLaunchEnvironment = test.launchEnvironmentForSetup?() ?? [:]
        // For now we do not support overriding Emerge defined keys
        let mergedLaunchEnvironments = emergeLaunchEnvironment.merging(testLaunchEnvironment) { (emergeValue, _) in emergeValue }
        
        let setupApp = XCUIApplication()
        setupApp.launchEnvironment = mergedLaunchEnvironments
        setupApp.launchArguments = test.launchArgumentsForSetup?() ?? []
        setupApp.launch()
        return setupApp
    }
  
}
