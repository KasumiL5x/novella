//
//  JSONTestViewController.swift
//  Novella
//
//  Created by Daniel Green on 18/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class JSONTestViewController: NSViewController {
	override func viewDidLoad() {
			super.viewDidLoad()
	}
	
	@IBAction func onWriteJSON(_ sender: NSButton) {
		let story = Story()
		
		do {
			let str = try Serialize.write(story: story)
			print(str)
		} catch {
			print("Failed to convert JSON.")
		}
	}
}
