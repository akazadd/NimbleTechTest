//
//  HomeViewModel.swift
//  NimbleTechTest
//
//  Created by A K Azad on 3/11/23.
//

import Foundation

protocol HomeViewModelProtocol {
    var responseData: [Survey]? { get set }
    func fetchServeyListFromAPI(completion: @escaping () -> Void)
}

class HomeViewModel: HomeViewModelProtocol {
	var responseData: [Survey]?
	var apiManager = ApiManager()
	var pageNumber = 1
	private var pageSize = 5
	var currentPage: Int = 0
	
	func fetchServeyListFromAPI(completion: @escaping () -> Void) {
		let urlString = Constants.surveyUrl.rawValue + "?page[number]=\(pageNumber)&page[size]=\(pageSize)"
		
		apiManager.callApi(urlString: urlString, method: .get, parameters: nil) { [unowned self] (result: Result<SurveyListModel, APIError>) in
			switch result {
				case .success(let response):
					if let newList = response.surveyList {
						if self.pageNumber == 1 {
							// If it's the first page, replace the existing data
							self.responseData = newList
						} else {
							// If it's not the first page, append the new data
							self.responseData?.append(contentsOf: newList)
						}
					}
					
					self.cacheSurveyData()
					completion()
				case .failure(let error):
					print("API Error: \(error)")
			}
		}
	}
	
	func loadCachedSurveys() {
		if let cachedSurveys = UserDefaults.standard.data(forKey: defaultKeys.cachedSurveyData) {
			if let decodedSurveys = try? JSONDecoder().decode([Survey].self, from: cachedSurveys) {
//				self.responseData = decodedSurveys
			}
		}
	}
	
	// Method to cache the fetched surveys
	private func cacheSurveyData() {
		if let surveysData = try? JSONEncoder().encode(responseData) {
			UserDefaults.standard.set(surveysData, forKey: defaultKeys.cachedSurveyData)
		}
	}
	
}

/*
 let xOffset = scrollview.contentOffset.x  // Store the current scroll offset
 scrollview.subviews.forEach { $0.removeFromSuperview() }  // Remove existing surveyViews
 
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
 // Restore the scroll offset after updating the content
 scrollview.contentOffset = CGPoint(x: xOffset, y: 0)
 
let totalPages = viewModel.responseData?.count ?? 0
// Calculate the content size based on the total number of pages
scrollview.contentSize = CGSize(width: view.frame.size.width * CGFloat(totalPages), height: view.frame.size.height)

// Iterate through existing views and update content
for (index, surveyView) in scrollview.subviews.enumerated() {
	guard let surveyView = surveyView as? SurveyView else { continue }
	
	let pageIndex = index % totalPages
	if let survey = viewModel.responseData?[pageIndex].attributes {
		// Configure the surveyView with content
		surveyView.dateLabel.text = survey.created_at?.formattedDateString()?.uppercased()
		surveyView.dayLabel.text = survey.created_at?.formattedDayString()
		surveyView.titleLabel.text = survey.title
		surveyView.queryLabel.text = survey.description
		let imageUrl = survey.cover_image_url
		let highResolutionImageUrl = (imageUrl ?? "") + "l"
		surveyView.backgroundImgView.kf.setImage(with: URL(string: highResolutionImageUrl))
		surveyView.pageControl.numberOfPages = totalPages
		surveyView.pageControl.currentPage = pageIndex
		surveyView.actionButton.tag = pageIndex
		
		surveyView.actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
	}
}
 */
