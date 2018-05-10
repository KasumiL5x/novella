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
	
	override init(uuid: NSUUID) {
		self._content = ""
		self._preview = ""
		self._directions = ""
		
		super.init(uuid: uuid)
	}
	
	// MARK: Getters/Setter
	public var Content: String {
		get{ return _content }
		set{ _content = newValue }
	}
	public var Preview: String {
		get{ return _preview }
	}
	public var Directions: String {
		get{ return _directions }
	}
	
	// MARK: Setters
	func setContent(_ content: String) {
		self._content = content
	}
	
	func setPreview(_ preview: String) {
		self._preview = preview
	}
	
	func setDirections(_ directions: String) {
		self._directions = directions
	}
}
