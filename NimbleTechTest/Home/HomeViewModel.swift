//
//  HomeViewModel.swift
//  NimbleTechTest
//
//  Created by A K Azad on 3/11/23.
//

import Foundation

class HomeViewModel {
    
    private let apiManager = ApiManager()
    
    func serveyList(pageNumber: Int, pageSize: Int) {
        let urlString = Constants.surveyUrl.rawValue + "?page[number]=\(pageNumber)&page[size]=\(pageSize)"
        print("urlString: \(urlString)")
        
        apiManager.callApi(urlString: urlString, method: "GET", parameters: nil) { (result: Result<SurveyListModel, APIError>) in
            switch result {
            case .success(let response):
                print("response: \(response)")
//                competion(.success(()))
            case .failure(let error):
//                if error == .accessTokenExpired {
//                    self.handleAccessTokenExpired()
//                }
//                competion(.failure(error))
                print(error)
            }
        }
    }
}
