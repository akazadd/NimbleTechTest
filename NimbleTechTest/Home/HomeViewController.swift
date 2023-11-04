//
//  HomeViewController.swift
//  NimbleTechTest
//
//  Created by A K Azad on 3/11/23.
//

import UIKit
import AMShimmer

class HomeViewController: UIViewController {

    @IBOutlet weak var backgroundImgView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var queryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var viewModel: HomeViewModel!
    
    static func instantiate() -> HomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! HomeViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        AMShimmer.start(for: backgroundImgView)
        viewModel.serveyList(pageNumber: 1, pageSize: 5)
        AMShimmer.stop(for: backgroundImgView)
    }
}
