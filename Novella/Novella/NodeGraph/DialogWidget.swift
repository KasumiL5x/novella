//
//  DialogWidget.swift
//  Novella
//
//  Created by Daniel Green on 02/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class DialogWidget: CanvasWidget {
	var _novellaDialog: Dialog?
	var _nameLabel: NSTextField
	
	init(node: Dialog, canvas: Canvas) {
		self._nameLabel = NSTextField()
		self._nameLabel.translatesAutoresizingMaskIntoConstraints = false
		self._nameLabel.isBezeled = false
		self._nameLabel.drawsBackground = false
		self._nameLabel.isEditable = false
		self._nameLabel.isSelectable = false
		self._nameLabel.textColor = NSColor.init(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0)
		self._nameLabel.stringValue = node.Name.isEmpty ? "unnamed" : node.Name
		
		self._novellaDialog = node
		

		// TODO: Don't use fixed size.
		super.init(frame: NSRect(x: node._editorPos.x, y: node._editorPos.y, width: 64.0, height: 64.0), canvas: canvas)
		
		self._nameLabel.sizeToFit()
		self._nameLabel.frame.origin = CGPoint(x: self.frame.width/2 - self._nameLabel.frame.width/2, y: self.frame.height/2)
		self.addSubview(self._nameLabel)
	}
	required init?(coder decoder: NSCoder) {
		fatalError("DialogWidget::init(coder) not implemented.")
	}
	
	override func onMove() {
		_novellaDialog?._editorPos = frame.origin
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if let context = NSGraphicsContext.current?.cgContext {
			context.saveGState()
			
			let path = NSBezierPath(roundedRect: bounds, xRadius: 2.0, yRadius: 2.0)
			NSColor.white.setFill()
			path.fill()
			
			context.restoreGState()
		}
	}
}
