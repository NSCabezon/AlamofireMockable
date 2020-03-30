import Foundation
import Alamofire

public class MockingURLProtocol: URLProtocol {
    
    public var cannedResponse: NSData?
    public let cannedHeaders = ["Content-Type" : "application/json; charset=utf-8"]
    
    // MARK: Properties
    struct PropertyKeys {
        static let handledByForwarderURLProtocol = "HandledByProxyURLProtocol"
    }
    
    lazy var session: URLSession = {
        
        let configuration: URLSessionConfiguration = {
            let configuration = URLSessionConfiguration.ephemeral
			configuration.httpAdditionalHeaders = Alamofire.HTTPHeaders.default.dictionary
            return configuration
        }()
        
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        return session
    }()
    
    var activeTask: URLSessionTask?
    
    // MARK: Class Request Methods
    public override class func canInit(with request: URLRequest) -> Bool {
        if URLProtocol.property(forKey: PropertyKeys.handledByForwarderURLProtocol, in: request) != nil {
            return false
        }
        
        return true
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        if let headers = request.allHTTPHeaderFields {
            do {
                return try URLEncoding.default.encode(request, with: headers)
            } catch {
                return request
            }
        }
        
        return request
    }
    
    public override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return false
    }
    
    // MARK: Loading Methods
    public override func startLoading() {
		if let data = Mocks.find(request),
          let url = request.url,
          let response = HTTPURLResponse(url: url,
                                  statusCode: 200,
                                 httpVersion: "HTTP/1.1",
                                headerFields: cannedHeaders) {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }
       
        client?.urlProtocolDidFinishLoading(self)
    }
    
    public override func stopLoading() {
        activeTask?.cancel()
    }
}

extension MockingURLProtocol: URLSessionDelegate {
    
    // MARK: NSURLSessionDelegate
    func URLSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceiveData data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }
    
    func URLSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let response = task.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
}
