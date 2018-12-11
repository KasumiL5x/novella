//
//  Bench.swift
//  novella
//
//  Created by Daniel Green on 10/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class CanvasBench: NSView {
	static let Roundness: CGFloat = 0.2
	static let Padding: CGFloat = 5.0
	
	private var _bglayer: CAShapeLayer
	private(set) var Items: [CanvasLink]
	private var _widthConstraint: NSLayoutConstraint?
	private var _heightConstraint: NSLayoutConstraint?
	
	init() {
		self._bglayer = CAShapeLayer()
		self.Items = []
		super.init(frame: NSMakeRect(0, 0, 1, 1))
		
		wantsLayer = true
		layer?.masksToBounds = false
		
		// bg layer
		_bglayer.fillColor = NSColor.fromHex("#FAFAFA").cgColor
		layer?.addSublayer(_bglayer)
		
		// inital sizing
		layoutItems()
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	func add(_ item: CanvasLink) {
		if(Items.contains(item)) {
			return
		}
		
		Items.append(item)
		addSubview(item)
		layoutItems()
	}
	
	func remove(_ item: CanvasLink) {
		guard let idx = Items.index(of: item) else {
			return
		}
		Items.remove(at: idx)
		item.removeFromSuperview()
		layoutItems()
	}
	
	func constrain(to: CanvasObject) {
		_widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: frame.width)
		_heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: frame.height)
		superview?.addConstraints([
			_widthConstraint!,
			_heightConstraint!,
			NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: to, attribute: .right, multiplier: 1.0, constant: 10.0),
			NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: to, attribute: .centerY, multiplier: 1.0, constant: 0.0)
		])
	}
	
	private func layoutItems() {
		// center all in x
		var lastY: CGFloat = CanvasBench.Padding
		Items.forEach{
			$0.frame.origin.x = CanvasBench.Padding
			$0.frame.origin.y = lastY
			lastY += $0.frame.height + CanvasBench.Padding
		}
		
		// compute new frame size including padding
		var newSize = subviewsSize(expandFrame: false)
		newSize.width += CanvasBench.Padding
		newSize.height += CanvasBench.Padding
		frame.size = newSize
		
		// update width and height constraints
		_widthConstraint?.constant = frame.width
		_heightConstraint?.constant = frame.height
		
		// recompute background path
		let radius = (max(bounds.width, bounds.height) * 0.5) * CanvasBench.Roundness
		_bglayer.path = NSBezierPath(roundedRect: bounds, xRadius: radius, yRadius: radius).cgPath
		
		setNeedsDisplay(bounds)
	}
}
