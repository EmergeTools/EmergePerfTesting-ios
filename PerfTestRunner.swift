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
                let setupApp = XCUIApplication()
                setupApp.launch()
                test.runInitialSetup(withApp: setupApp)
                print("Running two iterations for \(String(describing: aClass))")
                print("Iteration 1")
                let app1 = XCUIApplication()
                app1.launch()
                test.runIteration(withApp: app1)
                print("Iteration 2")
                let app2 = XCUIApplication()
                app2.launch()
                test.runIteration(withApp: app2)
            }
        }
    }
}
