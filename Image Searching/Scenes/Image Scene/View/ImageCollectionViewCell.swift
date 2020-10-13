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
    
    func configureCell(with image: UIImage) {
        DispatchQueue.main.async {
            self.itemImageView.image = image
        }
    }
}
