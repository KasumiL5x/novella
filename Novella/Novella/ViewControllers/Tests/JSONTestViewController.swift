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
		
		// set up some story graph and variable content
		let mq1 = try! story.MainGraph.makeGraph(name: "quest1")
		let _ = try! mq1.makeGraph(name: "objective1")
		let mq2 = try! story.MainGraph.makeGraph(name: "quest2")
		let _ = try! mq2.makeGraph(name: "objective1")
		let _ = try! mq2.makeGraph(name: "objective2")
		//
		let side = try! story.makeGraph(name: "side")
		let _ = try! side.makeGraph(name: "quest1")
		let _ = try! side.makeGraph(name: "quest2")
		//
		let chars = try! story.MainFolder.mkdir(name: "characters")
		let player = try! chars.mkdir(name: "player")
		let _ = try! player.mkvar(name: "health", type: .integer)
		let decs = try! story.MainFolder.mkdir(name: "choices")
		let _ = try! decs.mkvar(name: "talked_to_dave", type: .boolean)
		let _ = try! decs.mkvar(name: "completed_task", type: .boolean)
		
		do {
			let str = try Serialize.write(story: story)
			print(str)
		} catch {
			print("Failed to convert JSON.")
		}
	}
}
