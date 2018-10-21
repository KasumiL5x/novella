//
//  CanvasSelection.swift
//  novella
//
//  Created by dgreen on 12/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class CanvasSelection {
	// MARK: - Variables
	private let _canvas: Canvas
	var selectionDidChange: (([CanvasObject]) -> Void)?
	
	// MARK: - Properties
	private(set) var Selection: [CanvasObject] = []
	
	// MARK: - Initialization
	init(canvas: Canvas) {
		self._canvas = canvas
	}
	
	// MARK: - Selection Functions
	func select(_ object: CanvasObject, append: Bool) {
		select([object], append: append)
	}
	func select(_ objects: [CanvasObject], append: Bool) {
		if append {
			Selection = (Selection + objects)
			objects.forEach{$0.select()} // state change of new objects
		} else {
			Selection.forEach{$0.normal()} // state change of old objects
			Selection = objects
			objects.forEach{$0.select()}
		}
		
		selectionDidChange?(Selection)
	}
	
	func deselect(_ object: CanvasObject) {
		deselect([object])
	}
	func deselect(_ objects: [CanvasObject]) {
		objects.forEach { (obj) in
			if Selection.contains(obj) {
				obj.normal()
				Selection.remove(at: Selection.index(of: obj)!)
			}
		}
		
		selectionDidChange?(Selection)
	}
}
