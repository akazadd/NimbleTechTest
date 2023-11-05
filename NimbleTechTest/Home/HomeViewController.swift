//
//  HomeViewController.swift
//  NimbleTechTest
//
//  Created by A K Azad on 3/11/23.
//

import UIKit
import AMShimmer
import Kingfisher

class HomeViewController: UIViewController {
    
    var viewModel: HomeViewModelProtocol!
    var router: HomeRouter!
        
    private var scrollview = UIScrollView()
    
    static func instantiate() -> HomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! HomeViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(scrollview)
        fetchData(page: 1, size: 5)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollview.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    func configureScrollView(pages: Int) {
        scrollview.contentSize = CGSize(width: view.frame.size.width*5, height: view.frame.size.height)
        scrollview.isPagingEnabled = true
        
        for page in 0..<pages {
            let surveyView = SurveyView(frame: CGRect(x: CGFloat(page) * view.frame.size.width, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            
            let survey = viewModel.responseData?[page].attributes
            surveyView.dateLabel.text = survey?.created_at?.formattedDateString()
            surveyView.dayLabel.text = survey?.active_at?.formattedDayString()
            surveyView.titleLabel.text = survey?.title
            surveyView.queryLabel.text = survey?.description
            surveyView.backgroundImgView.kf.setImage(with: URL(string: survey?.cover_image_url ?? ""))
            surveyView.pageControl.numberOfPages = pages
            surveyView.pageControl.currentPage = page
            surveyView.actionButton.tag = page
            
            surveyView.actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
                        
            scrollview.addSubview(surveyView)
        }
    }
    
    func fetchData(page: Int, size: Int) {
        viewModel.fetchServeyListFromAPI(pageNumber: page, pageSize: size) { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }
    
    private func updateUI() {
        if scrollview.subviews.count == 2 {
            configureScrollView(pages: viewModel.responseData?.count ?? 0)
        }
    }
    
    @objc
    func onActionButtonTap() {
        
    }
    
    @objc func actionButtonTapped(_ sender: UIButton) {
        // Retrieve the index of the tapped survey view from the button's tag
        self.router.perform(.surveyDetails, from: self, attributes: viewModel.responseData?[sender.tag].attributes)
    }

}
