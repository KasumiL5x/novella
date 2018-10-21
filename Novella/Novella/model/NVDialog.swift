//
//  NVDialog.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVDialog: NVNode {
	// MARK: - Properties
	var Content: String = "" {
		didSet {
			NVLog.log("Dialog (\(ID)) content set to \"\(Content)\".", level: .info)
			_story.Delegates.forEach{$0.nvDialogContentDidChange(dialog: self)}
		}
	}
	var Directions: String = "" {
		didSet {
			NVLog.log("Dialog (\(ID)) directions set to \"\(Directions)\".", level: .info)
			_story.Delegates.forEach{$0.nvDialogDirectionsDidChange(dialog: self)}
		}
	}
	var Preview: String = "" {
		didSet {
			NVLog.log("Dialog (\(ID)) preview set to \"\(Preview)\".", level: .info)
			_story.Delegates.forEach{$0.nvDialogPreviewDidChange(dialog: self)}
		}
	}
	var Instigator: NVEntity? = nil {
		didSet {
			NVLog.log("Dialog (\(ID)) instigator set to (\(Instigator?.ID.uuidString ?? "nil")).", level: .info)
			_story.Delegates.forEach{$0.nvDialogInstigatorDidChange(dialog: self)}
		}
	}
}
