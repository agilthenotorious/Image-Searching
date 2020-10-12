//
//  ImageCollectionViewCell.swift
//  Image Searching
//
//  Created by Agil Madinali on 10/7/20.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ImageCollectionViewCell"
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    var operationQueue = OperationQueue()
    
    func configureCell(imageUrl: String, filter: ImageFilterType) {
//        FilterOperation.shared.downloadFilterImage(with: imageUrl, filter: filter) { image in
//            DispatchQueue.main.async {
//                self.itemImageView.image = image
//            }
//        }
        let filterOperation = FilterOperation(imageUrl: imageUrl, filter: filter)
        
        filterOperation.completionBlock = {
            guard let image = filterOperation.image else { return }
            DispatchQueue.main.async {
                self.itemImageView.image = image
            }
        }
        self.operationQueue.addOperation(filterOperation)
    }
}
