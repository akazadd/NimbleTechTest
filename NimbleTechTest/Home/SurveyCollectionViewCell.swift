//
//  SurveyCollectionViewCell.swift
//  NimbleTechTest
//
//  Created by Abul Kalam Azad on 12/11/23.
//

import UIKit

class SurveyCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var backgroundImgView: UIImageView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var dayLabel: UILabel!
	@IBOutlet weak var userImgView: UIImageView!
	@IBOutlet weak var actionButton: UIButton!
	@IBOutlet weak var queryLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var pageControl: UIPageControl!
	@IBOutlet weak var pageControl: CustomPageControl!

	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
