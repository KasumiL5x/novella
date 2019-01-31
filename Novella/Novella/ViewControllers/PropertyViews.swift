//
//  PropertyViewControllers.swift
//  novella
//
//  Created by Daniel Green on 14/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class TransformPropertyView: NSView {
	static func instantiate(obj: CanvasObject) -> TransformPropertyView {
		guard let view: TransformPropertyView = initFromNib() else {
			fatalError()
		}
		view.setupFor(obj: obj)
		return view
	}
	
	@IBOutlet weak public var _positionX: NSTextField!
	@IBOutlet weak public var _positionY: NSTextField!
	
	private var _obj: CanvasObject?
	
	private func setupFor(obj: CanvasObject) {
		_obj = obj
		
		wantsLayer = true
		layer?.backgroundColor = NSColor(named: "NVPropertyBackground")!.cgColor
		layer?.cornerRadius = (max(frame.width, frame.height) * 0.5) * 0.025
		
		_positionX.stringValue = "\(obj.frame.origin.x)"
		_positionY.stringValue = "\(obj.frame.origin.y)"
		obj.add(delegate: self) // autoremoves itself once nil thanks to the hash map
	}
	
	@IBAction func onPosX(_ sender: NSTextField) {
		moveObject()
	}
	@IBAction func onPosY(_ sender: NSTextField) {
		moveObject()
	}
	
	private func moveObject() {
		// get x double
		guard let xfmt = (_positionX.formatter as? NumberFormatter), let x = xfmt.number(from: _positionX.stringValue)?.floatValue else {
			return
		}
		// get y double
		guard let yfmt = (_positionY.formatter as? NumberFormatter), let y = yfmt.number(from: _positionY.stringValue)?.floatValue else {
			return
		}
		_obj?.move(to: NSMakePoint(CGFloat(x), CGFloat(y)))
	}
}
extension TransformPropertyView: CanvasObjectDelegate {
	func canvasObjectMoved(obj: CanvasObject) {
		_positionX.stringValue = "\(obj.frame.origin.x)"
		_positionY.stringValue = "\(obj.frame.origin.y)"
	}
}

class SequencePropertyView: NSView {
	@IBOutlet weak private var _label: NSTextField!
	@IBOutlet weak private var _parallel: NSButton!
	@IBOutlet weak private var _entry: NSButton!
	
	private var _sequence: CanvasSequence? = nil
	
	static func instantiate(sequence: CanvasSequence) -> SequencePropertyView {
		guard let view: SequencePropertyView = initFromNib() else {
			fatalError()
		}
		view.setupFor(sequence: sequence)
		return view
	}
	
	private func setupFor(sequence: CanvasSequence) {
		_sequence = sequence
		
		wantsLayer = true
		layer?.backgroundColor = NSColor(named: "NVPropertyBackground")!.cgColor
		layer?.cornerRadius = (max(frame.width, frame.height) * 0.5) * 0.025
		
		_label.stringValue = sequence.Sequence.Label
		_parallel.state = sequence.Sequence.Parallel ? .on : .off
		_entry.state = sequence.Sequence.Parent?.Entry == sequence.Sequence ? .on : .off
	}
	
	@IBAction func onLabelChanged(_ sender: NSTextField) {
		_sequence?.Sequence.Label = sender.stringValue
	}
	
	@IBAction func onParallelChanged(_ sender: NSButton) {
		_sequence?.Sequence.Parallel = sender.state == .on
	}
	
	@IBAction func onEntryChanged(_ sender: NSButton) {
		_sequence?.Sequence.Parent?.Entry = sender.state == .on ? _sequence?.Sequence : nil
	}
}

class GroupPropertyView: NSView {
	@IBOutlet weak private var _label: NSTextField!
	
	private var _group: CanvasGroup? = nil
	
	static func instantiate(group: CanvasGroup) -> GroupPropertyView {
		guard let view: GroupPropertyView = initFromNib() else {
			fatalError()
		}
		view.setupFor(group: group)
		return view
	}
	
	private func setupFor(group: CanvasGroup) {
		_group = group
		
		wantsLayer = true
		layer?.backgroundColor = NSColor(named: "NVPropertyBackground")!.cgColor
		layer?.cornerRadius = (max(frame.width, frame.height) * 0.5) * 0.025
		
		_label.stringValue = group.Group.Label
	}
	
	@IBAction func onLabelChanged(_ sender: NSTextField) {
		_group?.Group.Label = sender.stringValue
	}
}

class EventPropertyView: NSView {
	@IBOutlet weak var _label: NSTextField!
	@IBOutlet weak var _parallel: NSButton!
	@IBOutlet weak var _entry: NSButton!
	
	private var _event: CanvasEvent? = nil
	
	static func instantiate(event: CanvasEvent) -> EventPropertyView {
		guard let view: EventPropertyView = initFromNib() else {
			fatalError()
		}
		view.setupFor(event: event)
		return view
	}
	
	private func setupFor(event: CanvasEvent) {
		_event = event
		
		wantsLayer = true
		layer?.backgroundColor = NSColor(named: "NVPropertyBackground")!.cgColor
		layer?.cornerRadius = (max(frame.width, frame.height) * 0.5) * 0.025
		
		_label.stringValue = event.Event.Label
		_parallel.state = event.Event.Parallel ? .on : .off
		_entry.state = event.Event.Parent?.Entry == event.Event ? .on : .off
	}
	
	@IBAction func onLabelChanged(_ sender: NSTextField) {
		_event?.Event.Label = sender.stringValue
	}
	
	@IBAction func onParallelChanged(_ sender: NSButton) {
		_event?.Event.Parallel = sender.state == .on
	}
	
	@IBAction func onEntryChanged(_ sender: NSButton) {
		_event?.Event.Parent?.Entry = sender.state == .on ? _event?.Event : nil
	}
}
