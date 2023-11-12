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

protocol HomeViewModelDelegate: AnyObject {
	func surveysFetched()
}

class HomeViewModel {
	var responseData: [Survey] = []
	var apiManager = ApiManager()
	private var pageNumber = 1
	private var pageSize = 5
	private var totalPages = 1
	
	weak var delegate: HomeViewModelDelegate?
	
	func fetchSurveys() {
		let urlString = Constants.surveyUrl.rawValue + "?page[number]=\(pageNumber)&page[size]=\(pageSize)"
		
		apiManager.callApi(urlString: urlString, method: .get, parameters: nil) { [weak self] (result: Result<SurveyListModel, APIError>) in
			switch result {
				case .success(let response):
					self?.totalPages = response.meta?.pages ?? 0
					if let newList = response.surveyList {
						if self?.pageNumber == 1 {
							self?.responseData = newList
						} else {
							self?.responseData.append(contentsOf: newList)
						}
					}
					
					self?.cacheSurveyData()
					self?.delegate?.surveysFetched()
					
				case .failure(let error):
					print("API Error: \(error)")
					self?.delegate?.surveysFetched()
			}
		}
	}

	private func loadCachedSurveys() {
		if let cachedSurveys = UserDefaults.standard.data(forKey: defaultKeys.cachedSurveyData) {
			if let decodedSurveys = try? JSONDecoder().decode([Survey].self, from: cachedSurveys) {
				self.responseData = decodedSurveys
			}
		}
	}
	
	// Method to cache the fetched surveys
	private func cacheSurveyData() {
		if let surveysData = try? JSONEncoder().encode(responseData) {
			UserDefaults.standard.set(surveysData, forKey: defaultKeys.cachedSurveyData)
		}
	}
	
	func incrementPageNumber() {
		pageNumber += 1
	}
	
	func numberOfItemsInSection() -> Int {
		return responseData.count
	}
	
	func surveyAt(index: Int) -> SurveyAttributes? {
		return responseData[index].attributes
	}
	
	func totalItemCount() -> Int {
		return responseData.count
	}
	
	func setPageNumberForHandleRefresh() {
		pageNumber = 1
	}
	
	func shouldPaginationBeCalled() -> Bool {
		if pageNumber <= totalPages {
			return true
		} else {
			return false
		}
	}
}
