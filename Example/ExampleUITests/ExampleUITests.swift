import XCTest
import EMGPerfTesting

class ExamplePerfTest: NSObject, EMGPerfTest {
    func runInitialSetup(withApp app: XCUIApplication) {
        app.launch()
    }

    func runIteration(withApp app: XCUIApplication) {
        app.launch()
        app.buttons["Button"].tap()
        app.alerts["Title"].buttons["OK"].tap()
    }
}

class ExampleUITests: XCTestCase {
    func testExample() throws {
        PerfTestRunner.runAllPerfTestsForBundle(ofClass: ExampleUITests.self)
    }
}
