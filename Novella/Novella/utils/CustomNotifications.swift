//
//  CustomNotifications.swift
//  novella
//
//  Created by Daniel Green on 14/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

extension NSNotification.Name {
	static let nvCanvasSelectionChanged = NSNotification.Name("nvCanvasSelectionChanged")
	static let nvCanvasObjectDoubleClicked = NSNotification.Name("nvCanvasObjectDoubleClicked")
	static let nvCanvasSetupForGroup = NSNotification.Name("nvCanvasSetupForGroup")
	static let nvCanvasSetupForBeat = NSNotification.Name("nvCanvasSetupForBeat")
}
