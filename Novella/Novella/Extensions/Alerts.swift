//
//  Alerts.swift
//  novella
//
//  Created by Daniel Green on 27/09/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

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
