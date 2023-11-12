//
//  CustomPageControl.swift
//  NimbleTechTest
//
//  Created by Abul Kalam Azad on 12/11/23.
//

import UIKit

protocol CustomPageControlDelegate: AnyObject {
	func customPageControl(_ pageControl: UIPageControl, didTapIndicatorAtIndex index: Int)
}

class CustomPageControl: UIPageControl {
	
	weak var delegate: CustomPageControlDelegate?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupTapGesture()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupTapGesture()
	}
	
	private func setupTapGesture() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		addGestureRecognizer(tapGesture)
	}
	
	@objc private func handleTap(_ gesture: UITapGestureRecognizer) {
		let tapPoint = gesture.location(in: self)
		if let tappedIndicatorIndex = indicatorIndex(for: tapPoint) {
			currentPage = tappedIndicatorIndex
			delegate?.customPageControl(self, didTapIndicatorAtIndex: tappedIndicatorIndex)
		}
	}
	
	private func indicatorIndex(for tapPoint: CGPoint) -> Int? {
		let indicatorSize: CGFloat = 7.0 // Adjust this value according to your indicator size
		let spacing: CGFloat = 10.0 // Adjust this value according to your spacing between indicators
		
		let totalWidth = CGFloat(numberOfPages) * indicatorSize + CGFloat(numberOfPages - 1) * spacing
		let startX = (bounds.size.width - totalWidth) / 2.0
		
		if tapPoint.x >= startX && tapPoint.x < startX + totalWidth {
			let relativeX = tapPoint.x - startX
			let indicatorIndex = Int(relativeX / (indicatorSize + spacing))
			return indicatorIndex
		}
		
		return nil
	}
}
