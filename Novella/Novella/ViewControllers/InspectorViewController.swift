//
//  InspectorViewController.swift
//  novella
//
//  Created by Daniel Green on 14/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class InspectorViewController: NSViewController {
	private var _currentFocus: CanvasObject? = nil
	
	override func viewDidAppear() {
		view.window?.level = .floating
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(InspectorViewController.onCanvasSelectionChanged), name: NSNotification.Name.nvCanvasSelectionChanged, object: nil)
	}
	
	@objc private func onCanvasSelectionChanged(_ sender: NSNotification) {
		guard let selection = sender.userInfo?["selection"] as? [CanvasObject] else {
			return
		}
		
		// handle no selection
		if selection.isEmpty {
			_currentFocus = nil
			setupForNil()
			return
		}
		
		if selection.count > 1 {
			print("You have selected multiple objects but only the first object's properties are shown for now.")
		}
		
		// if the same, do nothing
		if _currentFocus == selection[0] {
			print("Selected an already selected object; doing nothing.")
			return
		}
		
		// store new selection focus
		_currentFocus = selection[0]
		// clear existing controls
		setupForNil()
		
		switch _currentFocus {
		case let asGroup as CanvasGroup:
			setupFor(group: asGroup)
			
		case let asBeat as CanvasBeat:
			setupFor(beat: asBeat)
			
		case let asEvent as CanvasEvent:
			setupFor(event: asEvent)
			
		default:
			print("Received nvCanvasSelectionChanged notification but the selection was unknown.")
		}
	}
	
	private func setupForNil() {
		view.subviews.removeAll()
	}
	
	private func setupFor(group: CanvasGroup) {
		print("Alan please implement groups.")
	}
	
	private func setupFor(beat: CanvasBeat) {
		let xform = TransformPropertyView.instantiate(obj: beat)
		view.addSubview(xform)
		
		let props = BeatPropertyView.instantiate(beat: beat)
		view.frame.origin.y = xform.frame.maxY
		view.addSubview(props)
	}
	
	private func setupFor(event: CanvasEvent) {
		print("Alan please implement events.")
	}
}
