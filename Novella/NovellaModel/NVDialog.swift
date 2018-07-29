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
	private var _directions: String
	private var _speaker: NVEntity?
	
	// MARK: - Properties -
	public var Content: String {
		get { return _content }
		set {
			_content = newValue
			
			NVLog.log("Dialog (\(self.UUID)) content set to (\(_content)).", level: .info)
			_manager.Delegates.forEach{$0.onStoryDialogContentChanged(content: _content, node: self)}
		}
	}
	public var Directions: String {
		get { return _directions }
		set {
			_directions = newValue
			
			NVLog.log("Dialog (\(self.UUID)) directions set to (\(_directions)).", level: .info)
			_manager.Delegates.forEach{$0.onStoryDialogDirectionsChanged(directions: _directions, node: self)}
		}
	}
	public var Speaker: NVEntity? {
		get{ return _speaker }
		set {
			_speaker = newValue
			
			NVLog.log("Dialog (\(self.UUID)) speaker set to (\(_speaker?.UUID.uuidString ?? "nil")).", level: .info)
			_manager.Delegates.forEach{$0.onStoryDialogSpeakerChanged(speaker: _speaker, node: self)}
		}
	}
	
	// MARK: - Initialization -
	override init(manager: NVStoryManager, uuid: NSUUID) {
		self._content = ""
		self._directions = ""
		self._speaker = nil
		super.init(manager: manager, uuid: uuid)
	}
}
