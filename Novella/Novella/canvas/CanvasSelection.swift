//
//  CanvasSelection.swift
//  novella
//
//  Created by dgreen on 07/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class CanvasSelection {
	private(set) var Selection: [CanvasObject] = []
	
	func select(_ obj: CanvasObject, append: Bool) {
		select([obj], append: append)
	}
	func select(_ objs: [CanvasObject], append: Bool) {
		if append {
			Selection = Selection + objs
			objs.forEach{$0.CurrentState = .selected}
		} else {
			Selection.forEach{$0.CurrentState = .normal}
			Selection = objs
			Selection.forEach{$0.CurrentState = .selected}
		}
	}

	func deselect(_ obj: CanvasObject) {
		deselect([obj])
	}
	func deselect(_ objs: [CanvasObject]) {
		objs.forEach { (obj) in
			if let idx = Selection.index(of: obj) {
				obj.CurrentState = .normal
				Selection.remove(at: idx)
			}
		}
	}
	
	func clear() {
		Selection.forEach{$0.CurrentState = .normal}
		Selection = []
	}
}
