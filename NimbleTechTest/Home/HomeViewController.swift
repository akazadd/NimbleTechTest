//
//  HomeViewController.swift
//  NimbleTechTest
//
//  Created by A K Azad on 3/11/23.
//

import UIKit
import AMShimmer

class HomeViewController: UIViewController {
    
    var viewModel: HomeViewModelProtocol!
    
    private var scrollview = UIScrollView()
    
    static func instantiate() -> HomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! HomeViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchData(page: 1, size: 5)
//        scrollview.backgroundColor = .red
        view.addSubview(scrollview)
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollview.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
    }
    
    func configureScrollView(pages: Int) {
        scrollview.contentSize = CGSize(width: view.frame.size.width*5, height: view.frame.size.height)
        scrollview.isPagingEnabled = true
        
        for x in 0..<pages {
            let surveyView = SurveyView(frame: CGRect(x: CGFloat(x) * view.frame.size.width, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            surveyView.backgroundColor = .systemBlue
            
            let survey = viewModel.responseData?[x].attributes
            surveyView.dateLabel.text = survey?.created_at?.formattedDateString()
            surveyView.dayLabel.text = survey?.active_at?.formattedDayString()
            surveyView.titleLabel.text = survey?.title
            surveyView.queryLabel.text = survey?.description
            
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
//        dateLabel.text = viewModel.responseData?[0].attributes?.created_at?.formattedDateString()
//        dayLabel.text = viewModel.responseData?[0].attributes?.active_at?.formattedDayString()
//        titleLabel.text = viewModel.responseData?[0].attributes?.title ?? ""
//        queryLabel.text = viewModel.responseData?[0].attributes?.description ?? ""
        if scrollview.subviews.count == 2 {
            configureScrollView(pages: viewModel.responseData?.count ?? 0)
        }
    }
}
