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
            surveyView.contentView.layerGradient()
            
//            surveyView.actionButton.addTarget(self, action: #selector(onActionButtonTap), for: .touchUpInside)
                        
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
}

extension UIView {
    func layerGradient() {
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = self.frame.size
        layer.frame.origin = CGPoint(x: 0.0,y: 0.0)
//        layer.cornerRadius = CGFloat(frame.width / 20)

        let color0 = UIColor(red:255.0/255, green:255.0/255, blue:255.0/255, alpha:0.8).cgColor
        let color1 = UIColor(red:255.0/255, green:255.0/255, blue: 255.0/255, alpha:0.5).cgColor
        
        layer.colors = [color0,color1]
        self.layer.insertSublayer(layer, at: 0)
    }
}
