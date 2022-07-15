import Foundation
import XCTest

@objc public protocol EMGPerfTest: NSObjectProtocol {
    /// This setup function is run once before all the iterations of the perf test. It can be used, for example, to
    /// log a test user in before doing some perf test that requires a logged in state. Do _not_ create an instance
    /// of XCUIApplication for the target app (i.e., XCUIApplication()) yourself. Only use the one provided, `app`.
    /// - Parameter app: an instance of XCUIApplication for the target app, i.e. XCUIApplication()
    func runInitialSetup(withApp app: XCUIApplication)

    /// This function is run repeatedly to collect performance data. Do _not_ create an instance
    /// of XCUIApplication for the target app (i.e., XCUIApplication()) yourself. Only use the one provided, `app`.
    /// - Parameter app: an instance of XCUIApplication for the target app, i.e. XCUIApplication()
    func runIteration(withApp app: XCUIApplication)
}
