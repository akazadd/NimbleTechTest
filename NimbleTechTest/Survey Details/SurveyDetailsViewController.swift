//
//  SurveyDetailsViewController.swift
//  NimbleTechTest
//
//  Created by A K Azad on 5/11/23.
//

import UIKit
import Kingfisher

class SurveyDetailsViewController: UIViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var queryLbl: UILabel!
    @IBOutlet weak var startServeyBtn: UIButton!
    
    var surveyInfo: SurveyAttributes?
    
    static func instantiate() -> SurveyDetailsViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! SurveyDetailsViewController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        startServeyBtn.layer.cornerRadius = 8
        startServeyBtn.clipsToBounds = true
        
        setupSurveyInfo()
    }
    
    func setupSurveyInfo() {
        guard let surveyInfo = surveyInfo else {
            return
        }
        
        titleLbl.text = surveyInfo.title
        queryLbl.text = surveyInfo.description
    }

}
