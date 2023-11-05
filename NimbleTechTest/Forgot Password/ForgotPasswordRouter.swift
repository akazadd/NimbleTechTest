//
//  ForgotPasswordRouter.swift
//  NimbleTechTest
//
//  Created by A K Azad on 6/11/23.
//

import UIKit

enum ForgotPasswordSegue {
    case login
}

protocol ForgotPasswordRouter {
    func perform(_ segue: ForgotPasswordSegue, from source: ForgotPasswordViewController)
}

class DefaultForgotPasswordRouter: ForgotPasswordRouter {
    func perform(_ segue: ForgotPasswordSegue, from source: ForgotPasswordViewController) {
        source.navigationController?.popViewController(animated: true)
    }
}
