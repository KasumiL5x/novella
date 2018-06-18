//
//  NVNode.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVNode: NVObject {
	// MARK: - Variables -
	private var _preview: String
	
	// MARK: - Properties -
	public var Preview: String {
		get { return _preview }
		set {
			_preview = newValue
			_manager.Delegates.forEach{$0.onStoryNodePreviewChanged(preview: _preview, node: self)}
		}
	}
	
	// MARK: - Initialization -
	override init(manager: NVStoryManager, uuid: NSUUID) {
		self._preview = ""
		super.init(manager: manager, uuid: uuid)
	}
	
	// MARK: - Functions -
	
	// MARK: Virtual
	public override func isLinkable() -> Bool {
		return true
	}
}
