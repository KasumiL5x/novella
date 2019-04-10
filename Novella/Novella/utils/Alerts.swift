//
//  Alerts.swift
//  novella
//
//  Created by Daniel Green on 10/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Cocoa

class Alerts {
	static func okCancel(msg: String, info: String, style: NSAlert.Style = .warning) -> Bool {
		let alert = NSAlert()
		alert.messageText = msg
		alert.informativeText = info
		alert.alertStyle = style
		alert.addButton(withTitle: "Cancel")
		alert.addButton(withTitle: "OK")
		return alert.runModal() == .alertSecondButtonReturn
	}
}

