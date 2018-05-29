//
//  NVDialog.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVDialog: NVNode {
	fileprivate var _content: String
	fileprivate var _preview: String
	fileprivate var _directions: String
	
	override init(uuid: NSUUID) {
		self._content = ""
		self._preview = ""
		self._directions = ""
		
		super.init(uuid: uuid)
	}
	
	public var Content: String {
		get { return _content }
		set {
			_content = newValue
			NVStoryManager.shared.Delegates.forEach{$0.onStoryDialogContentChanged(content: _content, node: self)}
		}
	}
	public var Preview: String {
		get { return _preview }
		set {
			_preview = newValue
			NVStoryManager.shared.Delegates.forEach{$0.onStoryDialogPreviewChanged(preview: _preview, node: self)}
		}
	}
	public var Directions: String {
		get { return _directions }
		set {
			_directions = newValue
			NVStoryManager.shared.Delegates.forEach{$0.onStoryDialogDirectionsChanged(directions: _directions, node: self)}
		}
	}
}
