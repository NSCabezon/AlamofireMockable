import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AlamofireMockableTests.allTests),
    ]
}
#endif
