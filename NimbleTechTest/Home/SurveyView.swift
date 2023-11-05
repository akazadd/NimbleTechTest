//
//  SurveyView.swift
//  NimbleTechTest
//
//  Created by A K Azad on 5/11/23.
//

import UIKit

class SurveyView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backgroundImgView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var queryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
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
    }
}
