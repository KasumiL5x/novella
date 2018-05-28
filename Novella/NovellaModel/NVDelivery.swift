//
//  NVDelivery.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVDelivery: NVNode {
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
			Delegates.forEach{$0.onStoryDeliveryContentChanged(content: _content, node: self)}
		}
	}
	public var Preview: String {
		get { return _preview }
		set {
			_preview = newValue
			Delegates.forEach{$0.onStoryDeliveryPreviewChanged(preview: _preview, node: self)}
		}
	}
	public var Directions: String {
		get { return _directions }
		set {
			_directions = newValue
			Delegates.forEach{$0.onStoryDeliveryDirectionsChanged(directions: _directions, node: self)}
		}
	}
}
