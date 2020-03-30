//
//  File.swift
//  
//
//  Created by Ivan Cabezon on 27/03/2020.
//

import Foundation

@testable import AlamofireMockable

enum Environment: EnvironmentInfo {
	case local
	
	var baseURL: URL {
		return URL(string: "http://local.com")!
	}
}
