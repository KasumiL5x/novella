//
//  CanvasDelegate.swift
//  Novella
//
//  Created by Daniel Green on 12/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

protocol CanvasDelegate {
	// called when the selection changes
	func onSelectionChanged(selection: [LinkableWidget])
}
