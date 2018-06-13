//
//  NVDialog.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVDialog: NVNode {
	// MARK: - Variables -
	private var _content: String
	private var _preview: String
	private var _directions: String
	
	// MARK: - Properties -
	public var Content: String {
		get { return _content }
		set {
			_content = newValue
			_manager.Delegates.forEach{$0.onStoryDialogContentChanged(content: _content, node: self)}
		}
	}
	public var Preview: String {
		get { return _preview }
		set {
			_preview = newValue
			_manager.Delegates.forEach{$0.onStoryDialogPreviewChanged(preview: _preview, node: self)}
		}
	}
	public var Directions: String {
		get { return _directions }
		set {
			_directions = newValue
			_manager.Delegates.forEach{$0.onStoryDialogDirectionsChanged(directions: _directions, node: self)}
		}
	}
	
	// MARK: - Initialization -
	override init(manager: NVStoryManager, uuid: NSUUID) {
		self._content = ""
		self._preview = ""
		self._directions = ""
		super.init(manager: manager, uuid: uuid)
	}
}
