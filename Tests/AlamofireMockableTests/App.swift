//
//  File.swift
//  
//
//  Created by Ivan Cabezon on 27/03/2020.
//

import Foundation

typealias Apps = [App]

struct App: Codable {
    let id: Int
    let name: String
}
