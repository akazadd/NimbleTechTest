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
    
    var viewModel: HomeViewModelProtocol!
    
    static func instantiate() -> HomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! HomeViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchData(page: 1, size: 5)
    }
    
    func fetchData(page: Int, size: Int) {
        viewModel.fetchServeyListFromAPI(pageNumber: page, pageSize: size) { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }
    
    private func updateUI() {
        dateLabel.text = viewModel.responseData?[0].attributes?.created_at?.formattedDateString()
        dayLabel.text = viewModel.responseData?[0].attributes?.active_at?.formattedDayString()
        titleLabel.text = viewModel.responseData?[0].attributes?.title ?? ""
        queryLabel.text = viewModel.responseData?[0].attributes?.description ?? ""
    }
}
