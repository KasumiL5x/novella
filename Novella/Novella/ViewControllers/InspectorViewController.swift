//
//  InspectorViewController.swift
//  novella
//
//  Created by Daniel Green on 14/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class InspectorViewController: NSViewController {
	@IBOutlet weak private var _statusLabel: NSTextField!
	
	private var _currentFocus: CanvasObject? = nil
	
	override func viewDidAppear() {
		view.window?.level = .floating
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(InspectorViewController.onCanvasSelectionChanged), name: NSNotification.Name.nvCanvasSelectionChanged, object: nil)
	}
	
	func setupFor(object: CanvasObject) {
		// if the same, do nothing
		if _currentFocus == object {
			print("Selected an already selected object; doing nothing.")
			return
		}
		
		// store new selection focus
		_currentFocus = object
		// clear existing controls
		setupForNil()
		
		switch _currentFocus {
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
	
	@objc private func onCanvasSelectionChanged(_ sender: NSNotification) {
		guard let selection = sender.userInfo?["selection"] as? [CanvasObject] else {
			return
		}
		
		// handle no selection
		if selection.isEmpty {
			_currentFocus = nil
			setupForNil()
			_statusLabel.stringValue = "No selection."
			_statusLabel.isHidden = false
			return
		}
		
		if selection.count > 1 {
			print("You have selected multiple objects but only the first object's properties are shown for now.")
			setupForNil()
			_statusLabel.stringValue = "Multiple objects selected."
			_statusLabel.isHidden = false
			return
		}
		
		setupFor(object: selection[0])
	}
	
	private func setupForNil() {
		view.subviews.filter{$0 != _statusLabel}.reversed().forEach{$0.removeFromSuperview()}
	}
	
	private func setupFor(group: CanvasGroup) {
		weak var xform = TransformPropertyView.instantiate(obj: group)
		view.addSubview(xform!)
		xform!.translatesAutoresizingMaskIntoConstraints = false
		view.addConstraints([
			NSLayoutConstraint(item: xform!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: xform!.frame.width),
			NSLayoutConstraint(item: xform!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: xform!.frame.height),
			NSLayoutConstraint(item: xform!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 5.0),
			NSLayoutConstraint(item: xform!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
		])
		
		weak var props = GroupPropertyView.instantiate(group: group)
		view.addSubview(props!)
		props!.translatesAutoresizingMaskIntoConstraints = false
		view.addConstraints([
			NSLayoutConstraint(item: props!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: props!.frame.width),
			NSLayoutConstraint(item: props!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: props!.frame.height),
			NSLayoutConstraint(item: props!, attribute: .top, relatedBy: .equal, toItem: xform, attribute: .bottom, multiplier: 1.0, constant: 5.0),
			NSLayoutConstraint(item: props!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
		])
	}
	
	private func setupFor(sequence: CanvasSequence) {
		weak var xform = TransformPropertyView.instantiate(obj: sequence)
		view.addSubview(xform!)
		xform!.translatesAutoresizingMaskIntoConstraints = false
		view.addConstraints([
			NSLayoutConstraint(item: xform!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: xform!.frame.width),
			NSLayoutConstraint(item: xform!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: xform!.frame.height),
			NSLayoutConstraint(item: xform!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 5.0),
			NSLayoutConstraint(item: xform!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
		])
		
		weak var props = SequencePropertyView.instantiate(sequence: sequence)
		view.addSubview(props!)
		props!.translatesAutoresizingMaskIntoConstraints = false
		view.addConstraints([
			NSLayoutConstraint(item: props!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: props!.frame.width),
			NSLayoutConstraint(item: props!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: props!.frame.height),
			NSLayoutConstraint(item: props!, attribute: .top, relatedBy: .equal, toItem: xform, attribute: .bottom, multiplier: 1.0, constant: 5.0),
			NSLayoutConstraint(item: props!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
		])
	}
	
	private func setupFor(event: CanvasEvent) {
		weak var xform = TransformPropertyView.instantiate(obj: event)
		view.addSubview(xform!)
		xform!.translatesAutoresizingMaskIntoConstraints = false
		view.addConstraints([
			NSLayoutConstraint(item: xform!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: xform!.frame.width),
			NSLayoutConstraint(item: xform!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: xform!.frame.height),
			NSLayoutConstraint(item: xform!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 5.0),
			NSLayoutConstraint(item: xform!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
		])
		
		weak var props = EventPropertyView.instantiate(event: event)
		view.addSubview(props!)
		props!.translatesAutoresizingMaskIntoConstraints = false
		view.addConstraints([
			NSLayoutConstraint(item: props!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: props!.frame.width),
			NSLayoutConstraint(item: props!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: props!.frame.height),
			NSLayoutConstraint(item: props!, attribute: .top, relatedBy: .equal, toItem: xform, attribute: .bottom, multiplier: 1.0, constant: 5.0),
			NSLayoutConstraint(item: props!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
		])
	}
}
