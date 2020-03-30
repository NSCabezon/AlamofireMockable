import XCTest
import Alamofire

@testable import AlamofireMockable

final class AlamofireMockableTests: XCTestCase {
	var locApi: RequestManager = RequestManager(Environment.local, mockingProtocol: MockingURLProtocol.self)
	
	override func setUp() {
		
	}
	
    func testLocal() {
		let expect = expectation(description: "ajam")
		wait(for: [expect], timeout: 30)
		locApi.request("apps", method: .get)
			.responseDecodable { (response: DataResponse<Apps, AFError>) in
				switch response.result {
				case .success(let responseObj):
					print("PRO: \(responseObj)")
				case .failure(let error):
					print(error)
				}
				expect.fulfill()
		}
	}

    static var allTests = [
        ("testExample", testLocal),
    ]
}
