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
		obj.add(delegate: self)
		print("TODO: How and when do I remove this delegate? Is it auto removed when this class dies? Need to check.")
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

class BeatPropertyView: NSView {
	@IBOutlet weak private var _label: NSTextField!
	@IBOutlet weak private var _parallel: NSButton!
	@IBOutlet weak private var _entry: NSButton!
	
	private var _beat: CanvasBeat? = nil
	
	static func instantiate(beat: CanvasBeat) -> BeatPropertyView {
		guard let view: BeatPropertyView = initFromNib() else {
			fatalError()
		}
		view.setupFor(beat: beat)
		return view
	}
	
	private func setupFor(beat: CanvasBeat) {
		_beat = beat
		
		wantsLayer = true
		layer?.backgroundColor = NSColor(named: "NVPropertyBackground")!.cgColor
		layer?.cornerRadius = (max(frame.width, frame.height) * 0.5) * 0.025
		
		_label.stringValue = beat.Beat.Label
		_parallel.state = beat.Beat.Parallel ? .on : .off
		_entry.state = beat.Beat.Parent?.Entry == beat.Beat ? .on : .off
	}
	
	@IBAction func onLabelChanged(_ sender: NSTextField) {
		_beat?.Beat.Label = sender.stringValue
	}
	
	@IBAction func onParallelChanged(_ sender: NSButton) {
		_beat?.Beat.Parallel = sender.state == .on
	}
	
	@IBAction func onEntryChanged(_ sender: NSButton) {
		_beat?.Beat.Parent?.Entry = sender.state == .on ? _beat?.Beat : nil
	}
}
