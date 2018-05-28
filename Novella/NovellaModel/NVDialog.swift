//
//  NVDialog.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVDialog: NVNode {
	var _content: String
	var _preview: String
	var _directions: String
	
	override init(uuid: NSUUID, storyManager: NVStoryManager) {
		self._content = ""
		self._preview = ""
		self._directions = ""
		
		super.init(uuid: uuid, storyManager: storyManager)
	}
	
	// MARK: Getters/Setter
	public var Content: String {
		get { return _content }
		set {
			_content = newValue
			_delegate?.onStoryDialogContentChanged(content: _content, node: self)
		}
	}
	public var Preview: String {
		get { return _preview }
		set {
			_preview = newValue
			_delegate?.onStoryDialogPreviewChanged(preview: _preview, node: self)
		}
	}
	public var Directions: String {
		get { return _directions }
		set {
			_directions = newValue
			_delegate?.onStoryDialogDirectionsChanged(directions: _directions, node: self)
		}
	}
}
