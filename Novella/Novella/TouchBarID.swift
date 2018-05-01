//
//  TouchBarIdentifiers.swift
//  Novella
//
//  Created by Daniel Green on 01/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import AppKit

struct TouchBarID {
	struct Identifiers {
		static let Writer = NSTouchBar.CustomizationIdentifier(rawValue: "me.dgreen.novella.Writer")
	}
	
	struct Items {
		struct Writer {
			static let CreateNode = NSTouchBarItem.Identifier(rawValue: "me.dgreen.novella.Writer.CreateNode")
		}
	}
}
