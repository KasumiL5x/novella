//
//  JSONTestViewController.swift
//  Novella
//
//  Created by Daniel Green on 18/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class JSONTestViewController: NSViewController {
	let engine = Engine()
	
	override func viewDidLoad() {
			super.viewDidLoad()
	}
	
	@IBAction func onWriteJSON(_ sender: NSButton) {
		// set up some story graph and variable content
		let mq1 = try! engine.TheStory.MainGraph?.add(graph: engine.makeFlowGraph(name: "quest1"))
		try! mq1?.add(graph: engine.makeFlowGraph(name: "objective1"))
		let mq2 = try! engine.TheStory.MainGraph?.add(graph: engine.makeFlowGraph(name: "quest2"))
		try! mq2?.add(graph: engine.makeFlowGraph(name: "objective1"))
		try! mq2?.add(graph: engine.makeFlowGraph(name: "objective2"))
		let side = try! engine.TheStory.add(graph: engine.makeFlowGraph(name: "side"))
		try! side.add(graph: engine.makeFlowGraph(name: "quest1"))
		try! side.add(graph: engine.makeFlowGraph(name: "quest2"))
		//
		let chars = try! engine.TheStory.MainFolder?.add(folder: engine.makeFolder(name: "characters"))
		let player = try! chars?.add(folder: engine.makeFolder(name: "player"))
		try! player?.add(variable: engine.makeVariable(name: "health", type: .integer))
		let decs = try! engine.TheStory.MainFolder?.add(folder: engine.makeFolder(name: "choices"))
		try! decs?.add(variable: engine.makeVariable(name: "talked_to_dave", type: .boolean))
		try! decs?.add(variable: engine.makeVariable(name: "completed_task", type: .boolean))
		
		do {
			let str = try Serialize.write(engine: engine)
			print(str)
		} catch {
			print("Failed to convert JSON.")
		}
	}
}
