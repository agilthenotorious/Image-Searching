//
//  FilterOperation.swift
//  Image Searching
//
//  Created by Agil Madinali on 10/11/20.
//

import Foundation
import UIKit

class FilterOperation: Operation {
    
    var image: UIImage?
    var imageUrl: String
    var filter: ImageFilterType
    
    var isFinishedStored = false
    override var isFinished: Bool {
        get {
            return self.isFinishedStored
        }
        set {
            if self.isFinishedStored != newValue {
                willChangeValue(forKey: "isFinished")
                self.isFinishedStored = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    init(imageUrl: String, filter: ImageFilterType) {
        self.imageUrl = imageUrl
        self.filter = filter
    }
    
    override func start() {
        if self.isCancelled { return }
        NetworkManager.shared.downloadFilterImage(with: imageUrl, filter: filter) { image in
            if self.isCancelled { return }
            
            DispatchQueue.main.async {
                self.image = image
            }
            self.isFinished = true
        }
    }
}
