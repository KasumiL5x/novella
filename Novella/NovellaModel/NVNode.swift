//
//  NVNode.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVNode: NVObject {
	public enum SizeType: Int {
		case compact
		case small
		case medium
		case large
		case MAX
	}
	
	// MARK: - Variables -
	private var _preview: String
	private var _sizeType: SizeType
	
	// MARK: - Properties -
	public var Preview: String {
		get { return _preview }
		set {
			_preview = newValue
			_manager.Delegates.forEach{$0.onStoryNodePreviewChanged(preview: _preview, node: self)}
		}
	}
	public var Size: SizeType {
		get{ return _sizeType }
		set{
			_sizeType = newValue
			_manager.Delegates.forEach{$0.onStoryNodeSizeChanged(node: self)}
		}
	}
	
	// MARK: - Initialization -
	override init(manager: NVStoryManager, uuid: NSUUID) {
		self._preview = ""
		self._sizeType = .small
		super.init(manager: manager, uuid: uuid)
	}
	
	// MARK: - Functions -
	
	// MARK: Virtual
	public override func isLinkable() -> Bool {
		return true
	}
}
