//
//  NVEntity.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVEntity: NVIdentifiable {
	// MARK: - Variables
	var ID: NSUUID
	private let _story: NVStory
	
	// MARK: - Properties
	var Name: String = "" {
		didSet {
			NVLog.log("Entity (\(ID)) renamed (\(oldValue)->\(Name)).", level: .info)
			_story.Delegates.forEach{$0.nvEntityDidRename(entity: self)}
		}
	}
	var Synopsis: String = "" {
		didSet {
			NVLog.log("Entity (\(ID)) synopsis set to \"\(Synopsis)\".", level: .info)
			_story.Delegates.forEach{$0.nvEntitySynopsisDidChange(entity: self)}
		}
	}
	
	init(id: NSUUID, story: NVStory) {
		self.ID = id
		self._story = story
	}
}

extension NVEntity: Equatable {
	static func ==(lhs: NVEntity, rhs: NVEntity) -> Bool {
		return lhs.ID == rhs.ID
	}
}
