//
//  HomeViewController.swift
//  NimbleTechTest
//
//  Created by A K Azad on 3/11/23.
//

import UIKit
import AMShimmer
import Kingfisher
import MaterialComponents

protocol ScrollViewDelegate {
	func optionChanged(to option: Survey)
}

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
	
	var initialPage = 0
    
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
	
	private func setupContentView() {
		let subviews = scrollview.subviews
		for subview in subviews {
			subview.removeFromSuperview()
		}
		
		guard let data = viewModel.responseData else { return }
		
		self.scrollview.contentSize = CGSize(width: scrollview.frame.size.width * CGFloat(data.count), height: scrollview.frame.size.height)
		
		for i in 0..<data.count {
			var frame = CGRect()
			frame.origin.x = scrollview.frame.size.width * CGFloat(i)
			frame.origin.y = 0
			frame.size = scrollview.frame.size
			
			let surveyView = SurveyView(frame: frame)
			
			let survey = viewModel.responseData?[i].attributes
			surveyView.dateLabel.text = survey?.created_at?.formattedDateString()?.uppercased()
			surveyView.dayLabel.text = survey?.created_at?.formattedDayString()
			surveyView.titleLabel.text = survey?.title
			surveyView.queryLabel.text = survey?.description
			let imageUrl = survey?.cover_image_url
			let highResulutionImageUrl = (imageUrl ?? "") + "l"
			surveyView.backgroundImgView.kf.setImage(with: URL(string: highResulutionImageUrl))
			surveyView.pageControl.numberOfPages = data.count
			surveyView.pageControl.currentPage = i
			
			surveyView.pageControl.addTarget(self, action: #selector(onPageControlTap(_:)), for: .valueChanged)
			
			scrollview.addSubview(surveyView)
		}
		
		let index = 1
		scrollview.contentOffset = CGPoint(x: scrollview.frame.width * CGFloat(index), y: 0)
//		self.selectedOption = data[index]
	}
	
	@objc
	func didReceiveTap(sender: UITapGestureRecognizer) {
		guard let data = viewModel.responseData else { return }
		
		var index = Int(scrollview.contentOffset.x / scrollview.frame.width)
		index = index < data.count ? index : 0
//		self.selectedOption = data[index]
		
		let x = scrollview.contentOffset.x
		let nextRect = CGRect(x: x + scrollview.frame.width,
							  y: 0,
							  width: scrollview.frame.width,
							  height: scrollview.frame.height)
		
		scrollview.scrollRectToVisible(nextRect, animated: true)
	}
	
	func configureScrollView() {
		
		guard let viewModel = viewModel, let pages = viewModel.responseData?.count else { return }
		
		// Remove existing surveyViews
//		scrollview.subviews.forEach { $0.removeFromSuperview() }
		
		scrollview.contentSize = CGSize(width: view.frame.size.width * CGFloat(pages), height: view.frame.size.height)
		scrollview.isPagingEnabled = true
		
		for page in initialPage..<pages {
			
			let surveyView = SurveyView(frame: CGRect(x: CGFloat(initialPage) * view.frame.size.width, y: 0, width: view.frame.size.width, height: view.frame.size.height))
			
			let survey = viewModel.responseData?[page].attributes
			surveyView.dateLabel.text = survey?.created_at?.formattedDateString()?.uppercased()
			surveyView.dayLabel.text = survey?.created_at?.formattedDayString()
			surveyView.titleLabel.text = survey?.title
			surveyView.queryLabel.text = survey?.description
			let imageUrl = survey?.cover_image_url
			let highResulutionImageUrl = (imageUrl ?? "") + "l"
			surveyView.backgroundImgView.kf.setImage(with: URL(string: highResulutionImageUrl))
			surveyView.pageControl.numberOfPages = pages
			surveyView.pageControl.currentPage = initialPage
			
			
			
			// Set the tag to the page index
			surveyView.pageControl.tag = page

			// Add a new target action for the page control
			surveyView.pageControl.addTarget(self, action: #selector(onPageControlTap), for: .valueChanged)
			
			surveyView.actionButton.tag = page
			surveyView.actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
			
			initialPage += 1
			
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
//				self?.setupContentView()
                
                // End the refresh control
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc func actionButtonTapped(_ sender: UIButton) {
        // Retrieve the index of the tapped survey view from the button's tag
        self.router.perform(.surveyDetails, from: self, attributes: viewModel.responseData?[sender.tag].attributes)
    }
	
	@objc
	func onPageControlTap(_ sender: MDCPageControl) {
		
		print("page \(sender.currentPage) is selected")
		var offset = scrollview.contentOffset
		offset.x = CGFloat(sender.currentPage) * scrollview.bounds.size.width;
		scrollview.setContentOffset(offset, animated: true)
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
	
//	func scrollViewDidScroll(_ scrollView: UIScrollView) {
//		
//		guard viewModel.responseData != nil else { return }
//		
//		let x = scrollView.contentOffset.x
//		if x >=  scrollView.frame.size.width * CGFloat(viewModel.responseData!.count - 1) {
//			self.scrollview.contentOffset = CGPoint(x: scrollView.frame.size.width , y: 0)
//		} else if x < scrollView.frame.width {
//			self.scrollview.contentOffset = CGPoint(x: scrollView.frame.size.width * CGFloat(viewModel.responseData!.count), y: 0)
//		}
//	}
}
