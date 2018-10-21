//
//  Bench.swift
//  novella
//
//  Created by dgreen on 17/10/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class Bench<Item: NSView>: NSView {
	// MARK: - Variables
	private var _bgLayer = CAShapeLayer()
	private var _widthConstraint: NSLayoutConstraint?
	private var _heightConstraint: NSLayoutConstraint?
	
	// MARK: - Properties
	private(set) var Items: [Item] = []
	var Padding: CGFloat = 5.0 {
		didSet { layoutItems() }
	}
	var Roundness: CGFloat = 6.0 {
		didSet{ setNeedsDisplay(bounds) }
	}
	var LayoutChanged: (() -> Void)?
	
	override var frame: NSRect {
		didSet {
			_widthConstraint?.constant = frame.width
			_heightConstraint?.constant = frame.height
			setNeedsDisplay(bounds)
		}
	}
	
	// MARK: - Initialization
	init() {
		super.init(frame: NSMakeRect(0, 0, 1, 1)) // anythin non-zero
		
		// setup backing layer
		wantsLayer = true
		layer?.masksToBounds = false
		layer?.addSublayer(_bgLayer)
		
		layoutItems()
	}
	required init?(coder decoder: NSCoder) {
		fatalError("Bench::init(coder) not implemented.")
	}
	
	// MARK: - Functions
	func constrainTo(_ to: NSView) {
		_widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: frame.width)
		_heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: frame.height)
		superview?.addConstraints([
			_widthConstraint!,
			_heightConstraint!,
			NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: to, attribute: .right, multiplier: 1.0, constant: 10),
			NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: to, attribute: .centerY, multiplier: 1.0, constant: 0.0)
		])
	}
	
	func add(_ item: Item) {
		Items.append(item)
		addSubview(item)
		layoutItems()
	}
	
	func remove(_ item: Item) {
		guard let idx = Items.index(of: item) else {
			return
		}
		Items.remove(at: idx)
		item.removeFromSuperview()
		layoutItems()
	}
	
	func contains(_ item: Item) -> Bool {
		return Items.contains(item)
	}
	
	private func layoutItems() {
		// center all items in X
		var lastY: CGFloat = Padding
		Items.forEach{
			$0.frame.origin.x = Padding
			$0.frame.origin.y = lastY
			lastY += $0.frame.height + Padding
		}
		
		sizeToFit()
		
		LayoutChanged?()
	}
	
	private func sizeToFit() {
		// resize frame to fit subviews w/ some padding
		var newSize = subviewsSize(expandFrame: false)
		newSize.width += Padding
		newSize.height += Padding
		frame.size = newSize
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			_bgLayer.fillColor = NSColor.fromHex("#FAFAFA").cgColor
			_bgLayer.path = NSBezierPath(roundedRect: bounds, xRadius: Roundness, yRadius: Roundness).cgPath
			
			context.restoreGState()
		}
	}
}
