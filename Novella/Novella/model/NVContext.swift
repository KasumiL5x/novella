//
//  NVContext.swift
//  novella
//
//  Created by Daniel Green on 01/11/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVContext: NVNode {
	// MARK: - Properties
	var Content: String = "" {
		didSet {
			NVLog.log("Context (\(ID)) content set to \"\(Content)\".", level: .info)
			_story.Delegates.forEach{$0.nvContextContentDidChange(context: self)}
		}
	}
}
