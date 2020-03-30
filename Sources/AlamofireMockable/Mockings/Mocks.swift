import Foundation



public class Mock {
	public static func loadJSON<T: Decodable>(_ filename: String, as type: T.Type = T.self, inBundle bundle: Bundle = Bundle.main) -> T {
		let data: Data
		
		guard let filePath = bundle.path(forResource: filename, ofType: "json") else {
			fatalError("Couldn’t find \(filename) in main bundle.")
		}
		
		let fileURL = URL(fileURLWithPath: filePath)
		do {
			data = try Data(contentsOf: fileURL)
		} catch {
			fatalError("Couldn’t load \(filename) from main bundle:\n\(error)")
		}
		
		do {
			let decoder = JSONDecoder()
			return try decoder.decode(T.self, from: data)
		} catch {
			fatalError("Couldn’t parse \(filename) as \(T.self):\n\(error)")
		}
	}
}



struct Mocks {
	private static func loadJSONString(_ resource: String, action: String, in bundle: Bundle) -> String? {
		let jsonFile = [action, resource].joined(separator: "_")
		if let filePath = bundle.path(forResource: jsonFile, ofType: "json") {
			do {
				let jsonString = try String(contentsOfFile: filePath)
				return jsonString
			} catch {
				print(error)
				assert(false)
			}
		}
		print("Mock file not found: \(jsonFile)")
		return nil
	}
	
	private static func loadJSONObj<T: Decodable>(_ resource: String, action: String, in bundle: Bundle, as type: T.Type = T.self) -> T? {
		let jsonFile = [action, resource].joined(separator: "_")
		let resultObj = Mock.loadJSON(jsonFile, as: T.self, inBundle: bundle)
		return resultObj
	}
	
	static func find<T: Decodable>(_ request: URLRequest, in bundle: Bundle, as type: T.Type = T.self) -> T? {
		guard let parts = request.url?.pathComponents,
			let method = request.httpMethod else { return nil }
		
		let suffix = parts.suffix(from: 1).map { $0 }
		guard let jsonObj = loadJSONObj(suffix.joined(separator: "_"), action: method, in: bundle, as: type) else { return nil }
		return jsonObj
	}
	
	
	static func find(_ request: URLRequest) -> Data? {
		guard let parts = request.url?.pathComponents,
			let method = request.httpMethod else { return nil }
		
		let suffix = parts.suffix(from: 1).map { $0 }
		let mocksBundle = Bundle(url: Bundle.main.url(forResource: "Mocks", withExtension: "bundle")!)!
		guard let jsonString = loadJSONString(suffix.joined(separator: "_"), action: method, in: mocksBundle) else { return nil }
		
		return jsonString.data(using: String.Encoding.utf8)
	}
}
