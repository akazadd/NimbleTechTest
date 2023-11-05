//
//  HomeRouter.swift
//  NimbleTechTest
//
//  Created by Abul Kalam Azad on 5/11/23.
//

import UIKit

enum HomeSegue {
	case surveyDetails
}

protocol HomeRouter {
	func perform(_ segue: HomeSegue, from source: HomeViewController, attributes : SurveyListAttributes?)
}


class DefaultHomeRouter: HomeRouter {
    func perform(_ segue: HomeSegue, from source: HomeViewController, attributes : SurveyListAttributes?) {
        switch segue {
        case .surveyDetails:
            let vc = DefaultHomeRouter.makeSurveyDetailsViewController(with: attributes)
            vc.modalPresentationStyle = .automatic
            source.present(vc, animated: true, completion: nil)
        }
    }
}

// MARK: Helpers

private extension DefaultHomeRouter {
	
    static func makeSurveyDetailsViewController(with surveyAttributes: SurveyListAttributes?) -> UIViewController {
		let vc = SurveyDetailsViewController.instantiate()
        vc.surveyInfo = surveyAttributes
		return vc
	}
}
