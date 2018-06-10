//
//  NVDelivery.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVDelivery: NVNode {
	private var _content: String
	private var _preview: String
	private var _directions: String
	
	override init(manager: NVStoryManager, uuid: NSUUID) {
		self._content = ""
		self._preview = ""
		self._directions = ""
		
		super.init(manager: manager, uuid: uuid)
	}
	
	// MARK: Coding
	public required init?(coder aDecoder: NSCoder) {
		self._content = aDecoder.decodeObject(forKey: "_content") as! String
		self._preview = aDecoder.decodeObject(forKey: "_preview") as! String
		self._directions = aDecoder.decodeObject(forKey: "_directions") as! String
		super.init(coder: aDecoder)
	}
	public override func encode(with aCoder: NSCoder) {
		super.encode(with: aCoder)
		aCoder.encode(_content, forKey: "_content")
		aCoder.encode(_preview, forKey: "_preview")
		aCoder.encode(_directions, forKey: "_directions")
	}
	
	public var Content: String {
		get { return _content }
		set {
			_content = newValue
			_manager.Delegates.forEach{$0.onStoryDeliveryContentChanged(content: _content, node: self)}
		}
	}
	public var Preview: String {
		get { return _preview }
		set {
			_preview = newValue
			_manager.Delegates.forEach{$0.onStoryDeliveryPreviewChanged(preview: _preview, node: self)}
		}
	}
	public var Directions: String {
		get { return _directions }
		set {
			_directions = newValue
			_manager.Delegates.forEach{$0.onStoryDeliveryDirectionsChanged(directions: _directions, node: self)}
		}
	}
}
