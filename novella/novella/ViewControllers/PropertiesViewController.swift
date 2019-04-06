//
//  PropertiesViewController.swift
//  novella
//
//  Created by Daniel Green on 04/03/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class PropertiesViewController: NSViewController {
	private var _document: Document? = nil
	
	private weak var _xformView: PropertyTransformView?
	
	private var _selectedObject: CanvasObject?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(PropertiesViewController.onCanvasSelectionChanged), name: NSNotification.Name.nvCanvasSelectionChanged, object: nil)
		
		_xformView = PropertyTransformView.instantiate()
		if let xv = _xformView {
			view.addSubview(xv)
			xv.translatesAutoresizingMaskIntoConstraints = false
			constrain(a: xv, b: view)
			xv.disable()
		}
	}
	
	func setup(doc: Document) {
		_document = doc
	}
	
	@objc private func onCanvasSelectionChanged(_ sender: NSNotification) {
		guard let selection = sender.userInfo?["selection"] as? [CanvasObject] else {
			return
		}
		
		// handle no selection
		if selection.isEmpty {
			removeAllButDefaults()
			_xformView?.disable()
			_selectedObject = nil
			return;
		}
		
		if selection.count > 1 {
			print("You have selected multiple items but this is not supported.")
			removeAllButDefaults()
			_xformView?.disable()
			_selectedObject = nil
			return;
		}
		
		setupFor(object: selection[0])
	}
	
	private func setupFor(object: CanvasObject) {
		if _selectedObject == object {
			return
		}
		
		_selectedObject = object
		removeAllButDefaults()
		_xformView?.enable()
		
		switch _selectedObject {
		case let asGroup as CanvasGroup:
			setupFor(group: asGroup)
			
		case let asSequence as CanvasSequence:
			setupFor(sequence: asSequence)
			
		case let asEvent as CanvasEvent:
			setupFor(event: asEvent)
			
		default:
			print("Received nvCanvasSelectionChanged notification but the selection was unknown.")
		}
	}
	
	private func setupFor(group: CanvasGroup) {
		guard let doc = _document else {
			print("Tried to setup for Group but _document was not set.")
			return
		}
		
		print("Setup for group")
		_xformView?.setupFor(object: group)
		
		weak var groupPane = PropertyGroupView.instantiate()
		if let groupPane = groupPane {
			view.addSubview(groupPane)
			groupPane.translatesAutoresizingMaskIntoConstraints = false
			constrain(a: groupPane, b: _xformView!)
			groupPane.setupFor(group: group, doc: doc)
		}
	}
	
	private func setupFor(sequence: CanvasSequence) {
		guard let doc = _document else {
			print("Tried to setup for Sequence but _document was not set.")
			return
		}
		
		print("Setup for sequence")
		_xformView?.setupFor(object: sequence)
		
		weak var seqPane = PropertySequenceView.instantiate()
		if let seqPane = seqPane {
			view.addSubview(seqPane)
			seqPane.translatesAutoresizingMaskIntoConstraints = false
			constrain(a: seqPane, b: _xformView!)
			seqPane.setupFor(sequence: sequence, doc: doc)
		}
	}
	
	private func setupFor(event: CanvasEvent) {
		guard let doc = _document else {
			print("Tried to setup for Event but _document was not set.")
			return
		}
		
		print("Setup for event")
		_xformView?.setupFor(object: event)
		
		weak var eventPane = PropertyEventView.instantiate()
		if let eventPane = eventPane {
			view.addSubview(eventPane)
			eventPane.translatesAutoresizingMaskIntoConstraints = false
			constrain(a: eventPane, b: _xformView!)
			eventPane.setupFor(event: event, doc: doc)
		}
	}
	
	private func removeAllButDefaults() {
		// todo: test this actually works and test it removes constraints!
		print("Test this actually works and test it removes constraints!")
		for i in (0..<view.subviews.count).reversed() {
			if view.subviews[i] != _xformView {
				view.subviews.remove(at: i)
			}
		}
	}
	
	private func constrain(a: NSView, b: NSView) {
		self.view.addConstraints([
//			NSLayoutConstraint(item: a, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: a.frame.width),
			NSLayoutConstraint(item: a, attribute: .left, relatedBy: .equal, toItem: b, attribute: .left, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: a, attribute: .right, relatedBy: .equal, toItem: b, attribute: .right, multiplier: 1.0, constant: 0.0),
			NSLayoutConstraint(item: a, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: a.frame.height),
			NSLayoutConstraint(item: a, attribute: .top, relatedBy: .equal, toItem: b, attribute: (b == self.view) ? .top : .bottom, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: a, attribute: .centerX, relatedBy: .equal, toItem: b, attribute: .centerX, multiplier: 1.0, constant: 0)
		])
	}
}
