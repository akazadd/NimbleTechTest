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
	func perform(_ segue: HomeSegue, from source: HomeViewController, attributes : SurveyAttributes?)
}


class DefaultHomeRouter: HomeRouter {
    func perform(_ segue: HomeSegue, from source: HomeViewController, attributes : SurveyAttributes?) {
        switch segue {
        case .surveyDetails:
            let vc = DefaultHomeRouter.makeSurveyDetailsViewController(with: attributes)
//            vc.modalPresentationStyle = .automatic
//            source.present(vc, animated: true, completion: nil)
            source.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: Helpers

private extension DefaultHomeRouter {
	
    static func makeSurveyDetailsViewController(with surveyAttributes: SurveyAttributes?) -> UIViewController {
		let vc = SurveyDetailsViewController.instantiate()
        vc.surveyInfo = surveyAttributes
		return vc
	}
}
