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
    private var apiManager = ApiManager()

    func fetchServeyListFromAPI(pageNumber: Int, pageSize: Int, completion: @escaping () -> Void) {
        let urlString = Constants.surveyUrl.rawValue + "?page[number]=\(pageNumber)&page[size]=\(pageSize)"
        
        apiManager.callApi(urlString: urlString, method: "GET", parameters: nil) { [unowned self] (result: Result<SurveyListModel, APIError>) in
            switch result {
            case .success(let response):
                self.responseData = response.surveyList
                completion()
            case .failure(let error):
                print("API Error: \(error)")
            }
        }
    }
    
    func surveyTitle(index: Int) -> String {
        guard let responseData = responseData, let title = responseData[index].attributes?.title else {
            return ""
        }
        
        return title
    }
}
