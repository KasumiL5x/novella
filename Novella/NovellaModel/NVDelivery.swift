//
//  NVDelivery.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVDelivery: NVNode {
	fileprivate var _content: String
	fileprivate var _preview: String
	fileprivate var _directions: String
	
	override init(uuid: NSUUID, storyManager: NVStoryManager) {
		self._content = ""
		self._preview = ""
		self._directions = ""
		
		super.init(uuid: uuid, storyManager: storyManager)
	}
	
	public var Content: String {
		get { return _content }
		set {
			_content = newValue
			_storyManager.Delegates.forEach{$0.onStoryDeliveryContentChanged(content: _content, node: self)}
		}
	}
	public var Preview: String {
		get { return _preview }
		set {
			_preview = newValue
			_storyManager.Delegates.forEach{$0.onStoryDeliveryPreviewChanged(preview: _preview, node: self)}
		}
	}
	public var Directions: String {
		get { return _directions }
		set {
			_directions = newValue
			_storyManager.Delegates.forEach{$0.onStoryDeliveryDirectionsChanged(directions: _directions, node: self)}
		}
	}
}
