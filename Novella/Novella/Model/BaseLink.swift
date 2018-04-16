//
//  BaseLink.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

class BaseLink: Identifiable {
	var origin: Linkable?
	
	override init() {
		self.origin = nil
	}
}

extension BaseLink: Equatable {
	static func == (lhs: BaseLink, rhs: BaseLink) -> Bool {
		return lhs._uniqueID == rhs._uniqueID
	}
}
