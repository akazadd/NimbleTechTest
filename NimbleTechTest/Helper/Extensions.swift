//
//  Extensions.swift
//  NimbleTechTest
//
//  Created by A K Azad on 3/11/23.
//

import Foundation
import UIKit

extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}


extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}

extension String {
    func formattedDateString() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "EEEE, MMMM dd"
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    func formattedDayString() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: date)
        }
        return nil
    }
}

extension UIView {
    func applyGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        let colors: [UIColor] = [
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4),
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
        ]
        
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIViewController {
    func showAlert(title: String?, message: String, completionHandler: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler?() // Call the completion handler if it's not nil
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension UITextField {
    func setPlaceholderColor(_ color: UIColor) {
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "",
                                                   attributes: [NSAttributedString.Key.foregroundColor: color])
    }
}

extension UITextField {
    func addBorder(withColor color: UIColor, cornerRadius radius: CGFloat, borderWidth width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}

// Extension to handle letter spacing
extension UILabel {
	var letterSpacing: CGFloat {
		get {
			guard let attributedText = attributedText else { return 0 }
			return attributedText.attributes(at: 0, effectiveRange: nil)[.kern] as? CGFloat ?? 0
		}
		set {
			guard let text = text else { return }
			let attributedString = NSMutableAttributedString(string: text)
			attributedString.addAttribute(.kern, value: newValue, range: NSRange(location: 0, length: attributedString.length))
			attributedText = attributedString
		}
	}
}

// Extension to handle font weight
extension UIFont {
	func withWeight(_ weight: UIFont.Weight) -> UIFont {
		var attributes = fontDescriptor.fontAttributes
		var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]
		traits[.weight] = weight
		attributes[.name] = nil
		attributes[.traits] = traits
		attributes[.family] = "NeuzeitSLTStd"
		let descriptor = UIFontDescriptor(fontAttributes: attributes)
		return UIFont(descriptor: descriptor, size: pointSize)
	}
}

