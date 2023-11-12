//
//  HomeViewController.swift
//  NimbleTechTest
//
//  Created by A K Azad on 3/11/23.
//

import UIKit
import Kingfisher
import SkeletonView

class HomeViewController: UIViewController {
    
    var viewModel: HomeViewModel!
    var router: HomeRouter!
        
	@IBOutlet weak var collectionView: UICollectionView!
	    
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
        
        // Fetch data when the view loads
        fetchData()
		setupViewModel()
		setupCollectionView()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		SkeletonAppearance.default.multilineLastLineFillPercent = Int.random(in: 20...70)
		SkeletonAppearance.default.multilineCornerRadius = 8
		collectionView.isSkeletonable = true
		collectionView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: .darkClouds), transition: .crossDissolve(0.2))
	}
	
	func setupCollectionView() {
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.register(UINib(nibName: "SurveyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SurveyCollectionViewCell")
		
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top:0, left: 0, bottom: 60, right: 0)
		layout.itemSize = CGSize(width: view.bounds.size.width, height: view.bounds.size.height)
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		layout.scrollDirection = .horizontal
		collectionView!.collectionViewLayout = layout
	}
	
	func setupViewModel() {
		viewModel.delegate = self
	}
    
    func fetchData() {
		viewModel.fetchSurveys()
    }
    
    @objc func actionButtonTapped(_ sender: UIButton) {
        // Retrieve the index of the tapped survey view from the button's tag
        self.router.perform(.surveyDetails, from: self, attributes: viewModel.responseData[sender.tag].attributes)
    }
    
    @objc private func handleRefresh(_ sender: Any) {
        // Fetch new data from the API
		viewModel.setPageNumberForHandleRefresh()
        fetchData()
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModel.numberOfItemsInSection()
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SurveyCollectionViewCell", for: indexPath) as? SurveyCollectionViewCell else {
			return UICollectionViewCell()
		}
		
		guard let survey = viewModel.surveyAt(index: indexPath.row) else {
			return cell
		}
				
		cell.dateLabel.text = survey.created_at?.formattedDateString()?.uppercased()
		cell.dayLabel.text = survey.created_at?.formattedDayString()
		cell.titleLabel.text = survey.title
		cell.queryLabel.text = survey.description
		let imageUrl = survey.cover_image_url
		let highResulutionImageUrl = (imageUrl ?? "") + "l"
		cell.backgroundImgView.kf.setImage(with: URL(string: highResulutionImageUrl))
		cell.pageControl.numberOfPages = viewModel.responseData.count
		cell.pageControl.currentPage = indexPath.row
		cell.pageControl.isHidden = false
		
		cell.actionButton.tag = indexPath.row
		cell.actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
		
		cell.pageControl.delegate = self
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let lastItem = viewModel.totalItemCount() - 1
		if indexPath.row == lastItem {
			viewModel.incrementPageNumber()
			if viewModel.shouldPaginationBeCalled() {
				fetchData()
			}
		}
	}
	
}

extension HomeViewController: CustomPageControlDelegate {
	func customPageControl(_ pageControl: UIPageControl, didTapIndicatorAtIndex index: Int) {
		scrollToIndex(index: index)
	}
	
	func scrollToIndex(index: Int) {
		let indexPath = IndexPath(item: index, section: 0)
		collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
	}
	
}

extension HomeViewController: HomeViewModelDelegate {
	func surveysFetched() {
		self.collectionView.hideSkeleton()
		self.collectionView.reloadData()
		self.refreshControl.endRefreshing()
	}
}

extension HomeViewController: SkeletonCollectionViewDataSource {
	func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
		return "SurveyCollectionViewCell"
	}
}
