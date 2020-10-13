//
//  Sections.swift
//  Image Searching
//
//  Created by Agil Madinali on 10/8/20.
//

import Foundation

struct Sections {
    var provider: Provider
    var dataSource: [ImageProtocol]
}

protocol ImageProtocol {
    var imageUrl: String? { get }
    init(dict: [String: Any])
}

struct SplashImageInfo: ImageProtocol {
    var imageUrl: String?

    init(dict: [String: Any]) {
        self.imageUrl = dict["url"] as? String
    }
}

struct PexelsImageInfo: ImageProtocol {
    var imageUrl: String?
    
    init(dict: [String: Any]) {
        if let srcDict = dict["src"] as? [String: Any] {
            self.imageUrl = srcDict["medium"] as? String
        }
    }
}

struct PixabayImageInfo: ImageProtocol {
    var imageUrl: String?
    
    init(dict: [String: Any]) {
        self.imageUrl = dict["webformatURL"] as? String
    }
}
