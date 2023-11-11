//
//  HomeViewModel.swift
//  NimbleTechTest
//
//  Created by A K Azad on 3/11/23.
//

import Foundation

protocol HomeViewModelProtocol {
    var responseData: [SurveyList]? { get set }
    func fetchServeyListFromAPI(pageNumber: Int, pageSize: Int, completion: @escaping () -> Void)
}

class HomeViewModel: HomeViewModelProtocol {
	var responseData: [SurveyList]?
	var apiManager = ApiManager()
	
	func fetchServeyListFromAPI(pageNumber: Int, pageSize: Int, completion: @escaping () -> Void) {
		let urlString = Constants.surveyUrl.rawValue + "?page[number]=\(pageNumber)&page[size]=\(pageSize)"
		
		apiManager.callApi(urlString: urlString, method: .get, parameters: nil) { [unowned self] (result: Result<SurveyListModel, APIError>) in
			switch result {
				case .success(let response):
					self.responseData = response.surveyList
					self.cacheSurveyData()
					completion()
				case .failure(let error):
					print("API Error: \(error)")
			}
		}
	}
	
	func loadCachedSurveys() {
		if let cachedSurveys = UserDefaults.standard.data(forKey: defaultKeys.cachedSurveyData) {
			if let decodedSurveys = try? JSONDecoder().decode([SurveyList].self, from: cachedSurveys) {
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
	
}
