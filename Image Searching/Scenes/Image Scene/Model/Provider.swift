//
//  Provider.swift
//  Image Searching
//
//  Created by Agil Madinali on 10/8/20.
//

import Foundation

struct Provider: Hashable {
    var isOn: Bool = true
    var name: String
    var url: String
    var parameters: [String: String]
    var headers: [String: String]?
}
