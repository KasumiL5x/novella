//
//  CustomImageView.swift
//  novella
//
//  Created by Daniel Green on 19/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class CustomImageView: NSImageView {
	public var Filename: String?
	
	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		let succeeded = super.performDragOperation(sender)
		
		if succeeded {
			// HACK: https://stackoverflow.com/questions/44537356/swift-4-nsfilenamespboardtype-not-available-what-to-use-instead-for-registerfo
			let filenames = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String]
			Filename = filenames?.first
		}
		
		return succeeded
	}
}
