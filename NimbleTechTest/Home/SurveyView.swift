//
//  SurveyView.swift
//  NimbleTechTest
//
//  Created by A K Azad on 5/11/23.
//

import UIKit
import MaterialComponents

class SurveyView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backgroundImgView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var queryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var pageControl: UIPageControl!
    
//	@IBOutlet weak var pageControl: CustomPageControl!
	
	var pageControl = MDCPageControl()
	
	override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SurveyView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.applyGradient()
		
		dateLabel.font = UIFont(name: "NeuzeitSLTStd-Book", size: 13)?.withWeight(UIFont.Weight(rawValue: 800))
		dayLabel.letterSpacing = -0.08
		
		dayLabel.font = UIFont(name: "NeuzeitSLTStd-Book", size: 34)?.withWeight(UIFont.Weight(rawValue: 800))
		dayLabel.letterSpacing = -1
		
		titleLabel.font = UIFont(name: "NeuzeitSLTStd-Book", size: 28)?.withWeight(UIFont.Weight(rawValue: 2000))
		titleLabel.letterSpacing = -0.5
		
		queryLabel.font = UIFont(name: "NeuzeitSLTStd-Book", size: 17)?.withWeight(UIFont.Weight(rawValue: 400))
		queryLabel.letterSpacing = -0.41
		
		pageControl.translatesAutoresizingMaskIntoConstraints = false
		self.backgroundImgView.addSubview(pageControl)
		
		NSLayoutConstraint.activate([
			pageControl.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			pageControl.bottomAnchor.constraint(equalTo: titleLabel.topAnchor),
			pageControl.heightAnchor.constraint(equalToConstant: 40)
		])
		
    }
}
