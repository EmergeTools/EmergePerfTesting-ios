import Foundation
import XCTest

@objc public protocol PerfTest: NSObjectProtocol {
    func runInitialSetup(withApp app: XCUIApplication)
    func runIteration(withApp app: XCUIApplication)
}
