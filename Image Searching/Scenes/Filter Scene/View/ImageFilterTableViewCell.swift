//
//  ImageFilterTableViewCell.swift
//  Image Searching
//
//  Created by Agil Madinali on 10/8/20.
//

import UIKit

class ImageFilterTableViewCell: UITableViewCell {

    static let identifier = "ImageFilterTableViewCell"
    
    @IBOutlet weak var filterTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureLabel(typeName: String) {
        self.filterTypeLabel.text = typeName
    }
}
