//
//  RequestManager.swift
//  MockAlamofire
//
//  Created by Steigerwald, Kris S. (CONT) on 2/13/17.
//  Copyright © 2017 Velaru. All rights reserved.
//

import Foundation
import Alamofire
import HelpersSPM

public protocol EnvironmentInfo {
	var baseURL: URL { get }
}

public struct RequestConvertible: URLRequestConvertible {
	let url: URLConvertible
	let method: HTTPMethod
	let parameters: Parameters?
	let encoding: ParameterEncoding
	let headers: HTTPHeaders?

	public func asURLRequest() throws -> URLRequest {
		let request = try URLRequest(url: url, method: method, headers: headers)
		return try encoding.encode(request, with: parameters)
	}
}

public class RequestManager {
	let client: Alamofire.Session
	let baseURL: URL

	public init(_ env: EnvironmentInfo, mockingProtocol: URLProtocol.Type? = nil, pinningEnabled: Bool = true) {
		if let mockingProtocol = mockingProtocol {
			let configuration: URLSessionConfiguration = {
				let configuration = URLSessionConfiguration.default
				configuration.protocolClasses = [mockingProtocol]
				return configuration
			}()
			self.client = Alamofire.Session(configuration: configuration)
		} else {
			if pinningEnabled {
				self.client = Alamofire.Session(configuration: URLSessionConfiguration.af.default)
			} else {
				let manager = ServerTrustManager(evaluators: [env.baseURL.absoluteString : DisabledEvaluator()])
				let configuration = URLSessionConfiguration.af.default
				self.client = Alamofire.Session(configuration: configuration, serverTrustManager: manager)
			}
		}
		self.baseURL = env.baseURL
    }
	
	public func request(_ path: String,
						method: HTTPMethod = .get,
						parameters: Encodable? = nil,
						encoding: ParameterEncoding = URLEncoding.default,
						headers: HTTPHeaders? = nil,
						interceptor: RequestInterceptor? = nil) -> DataRequest {
		let url = baseURL.appendingPathComponent(path)
		let convertible = RequestConvertible(url: url,
											 method: method,
											 parameters: parameters?.asJSON,
											 encoding: encoding,
											 headers: headers)
		return client.request(convertible, interceptor: interceptor)
	}
	
	public func request<Parameters: Encodable>(_ path: String,
											   method: HTTPMethod = .get,
											   parameters: Parameters? = nil,
											   encoding: ParameterEncoding = URLEncoding.default,
											   headers: HTTPHeaders? = nil,
											   encoder: ParameterEncoder = URLEncodedFormParameterEncoder.default,
											   interceptor: RequestInterceptor? = nil) -> DataRequest {
		let url = baseURL.appendingPathComponent(path)
		return client.request(url, method: method, parameters: parameters, encoder: encoder, headers: headers, interceptor: interceptor)
	}
}
