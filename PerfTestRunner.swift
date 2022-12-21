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
                print("Testing perf test class \(String(describing: aClass))")
                print("Running initial setup for \(String(describing: aClass))")
                
                let setupApp = makeApplication(forTest: test)
                test.runInitialSetup(withApp: setupApp)
              
                print("Running two iterations for \(String(describing: aClass))")
                for i in 0..<2 {
                    print("Iteration \(i + 1)")
                    let app = makeApplication(forTest: test)
                    test.runIteration(withApp: app)
                }
            }
        }
    }
    
    private static func makeApplication(forTest test: EMGPerfTest) -> XCUIApplication {
        let setupApp = XCUIApplication()
        setupApp.launchEnvironment = test.launchEnvironmentForSetup?() ?? [:]
        setupApp.launchArguments = test.launchArgumentsForSetup?() ?? []
        setupApp.launch()
        return setupApp
    }
  
}
