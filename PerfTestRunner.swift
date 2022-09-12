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
                let setupApp = prepareApp(for: test, launchType: .setup)
                setupApp.launch()
                test.runInitialSetup(withApp: setupApp)
                print("Running two iterations for \(String(describing: aClass))")
                print("Iteration 1")
                let app1 = prepareApp(for: test, launchType: .iteration)
                app1.launch()
                test.runIteration(withApp: app1)
                print("Iteration 2")
                let app2 = prepareApp(for: test, launchType: .iteration)
                app2.launch()
                test.runIteration(withApp: app2)
            }
        }
    }

    private enum LaunchType {
        case setup
        case iteration
    }

    private static func prepareApp(for test: EMGPerfTest, launchType: LaunchType) -> XCUIApplication {
        let app = XCUIApplication()
        let env: [String: String]
        switch launchType {
        case .setup:
            env = test.launchEnvironmentForSetup?() ?? [:]
        case .iteration:
            env = test.launchEnvironmentForIterations?() ?? [:]
        }
        app.launchEnvironment.merge(env) { current, new in
            return new
        }

        return app
    }
}
