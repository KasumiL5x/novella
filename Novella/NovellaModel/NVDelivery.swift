//
//  NVDelivery.swift
//  Novella
//
//  Created by Daniel Green on 17/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVDelivery: NVNode {
	// MARK: - Variables -
	private var _content: String
	private var _directions: String
	
	// MARK: - Properties -
	public var Content: String {
		get { return _content }
		set {
			_content = newValue
			
			NVLog.log("Delivery (\(self.UUID)) content set to (\(_content)).", level: .info)
			_manager.Delegates.forEach{$0.onStoryDeliveryContentChanged(content: _content, node: self)}
		}
	}
	public var Directions: String {
		get { return _directions }
		set {
			_directions = newValue
			
			NVLog.log("Delivery (\(self.UUID)) directions set to (\(_directions)).", level: .info)
			_manager.Delegates.forEach{$0.onStoryDeliveryDirectionsChanged(directions: _directions, node: self)}
		}
	}
	
	// MARK: - Initialization -
	override init(manager: NVStoryManager, uuid: NSUUID) {
		self._content = ""
		self._directions = ""
		super.init(manager: manager, uuid: uuid)
	}
}
