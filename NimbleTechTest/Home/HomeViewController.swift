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
    
    var viewModel: HomeViewModel!
    var router: HomeRouter!
        
    private var scrollview = UIScrollView()
    
    static func instantiate() -> HomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! HomeViewController
        return vc
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add scrollview as a subview to view
        view.addSubview(scrollview)
        
        // Add refresh control to the view
        scrollview.refreshControl = refreshControl
		scrollview.delegate = self
        
        // Fetch data when the view loads
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollview.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.automaticallyAdjustsScrollIndicatorInsets = false
        scrollview.contentInset = .zero
        scrollview.scrollIndicatorInsets = .zero
        scrollview.contentOffset = CGPoint(x: 0.0, y: 0.0)
        scrollview.contentInsetAdjustmentBehavior = .never
    }
	
	func configureScrollView() {
		
		guard let viewModel = viewModel, let pages = viewModel.responseData?.count else { return }
		
		// Remove existing surveyViews
		scrollview.subviews.forEach { $0.removeFromSuperview() }
		
		scrollview.contentSize = CGSize(width: view.frame.size.width * CGFloat(pages), height: view.frame.size.height)
		scrollview.isPagingEnabled = true
		
		for page in 0..<pages {
			let surveyView = SurveyView(frame: CGRect(x: CGFloat(page) * view.frame.size.width, y: 0, width: view.frame.size.width, height: view.frame.size.height))
			
			let survey = viewModel.responseData?[page].attributes
			surveyView.dateLabel.text = survey?.created_at?.formattedDateString()?.uppercased()
			surveyView.dayLabel.text = survey?.created_at?.formattedDayString()
			surveyView.titleLabel.text = survey?.title
			surveyView.queryLabel.text = survey?.description
			let imageUrl = survey?.cover_image_url
			let highResulutionImageUrl = (imageUrl ?? "") + "l"
			surveyView.backgroundImgView.kf.setImage(with: URL(string: highResulutionImageUrl))
			surveyView.pageControl.numberOfPages = pages
			surveyView.pageControl.currentPage = page
			surveyView.actionButton.tag = page
			
			surveyView.actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
			
			scrollview.addSubview(surveyView)
		}
	}

    
    func fetchData() {
        // Show loading animation
        showLoadingAnimation()
        
        // Attempt to load cached data
		viewModel.loadCachedSurveys()
        
        viewModel.fetchServeyListFromAPI() { [weak self] in
            DispatchQueue.main.async {
                // Hide loading animation
                self?.hideLoadingAnimation()
				
                self?.configureScrollView()
                
                // End the refresh control
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc func actionButtonTapped(_ sender: UIButton) {
        // Retrieve the index of the tapped survey view from the button's tag
        self.router.perform(.surveyDetails, from: self, attributes: viewModel.responseData?[sender.tag].attributes)
    }
    
    @objc private func handleRefresh(_ sender: Any) {
        // Fetch new data from the API
		viewModel.pageNumber = 1
        fetchData()
    }
}

//MARK: Loader
extension HomeViewController {
    func showLoadingAnimation() {
        // Create and configure a UIActivityIndicatorView or a custom loading view
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
        loadingIndicator.tag = 123 // Assign a unique tag to the loading view
        view.addSubview(loadingIndicator)
    }

    func hideLoadingAnimation() {
        // Find and remove the loading view based on its tag
        if let loadingIndicator = view.viewWithTag(123) as? UIActivityIndicatorView {
            loadingIndicator.stopAnimating()
            loadingIndicator.removeFromSuperview()
        }
    }
}

extension HomeViewController: UIScrollViewDelegate {
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
		// Set this based on API response
		let totalPages = viewModel.responseData?.count ?? 0
		
		// Check if the user has scrolled to the last page
		if currentPage == totalPages - 1 {
			// Fetch the next page
			viewModel.pageNumber +=  1
			fetchData()
		}
	}
}
