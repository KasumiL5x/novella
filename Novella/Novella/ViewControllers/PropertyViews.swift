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
	}
	
	@IBAction func onLabelChanged(_ sender: NSTextField) {
		_beat?.Beat.Label = sender.stringValue
	}
	
	@IBAction func onParallelChanged(_ sender: NSButton) {
		_beat?.Beat.Parallel = sender.state == .on
	}
}
