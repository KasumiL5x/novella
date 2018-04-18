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
		
		// set up some story graph and variable content
		let mainGraph = try! engine.TheStory.add(graph: engine.makeFlowGraph(name: "main"))
		let mq1 = try! mainGraph.add(graph: engine.makeFlowGraph(name: "quest1"))
		try! mq1.add(graph: engine.makeFlowGraph(name: "objective1"))
		let mq2 = try! mainGraph.add(graph: engine.makeFlowGraph(name: "quest2"))
		try! mq2.add(graph: engine.makeFlowGraph(name: "objective1"))
		try! mq2.add(graph: engine.makeFlowGraph(name: "objective2"))
		let side = try! engine.TheStory.add(graph: engine.makeFlowGraph(name: "side"))
		try! side.add(graph: engine.makeFlowGraph(name: "quest1"))
		try! side.add(graph: engine.makeFlowGraph(name: "quest2"))
		//
		let mainFolder = try! engine.TheStory.add(folder: engine.makeFolder(name: "story"))
		let chars = try! mainFolder.add(folder: engine.makeFolder(name: "characters"))
		let player = try! chars.add(folder: engine.makeFolder(name: "player"))
		try! player.add(variable: engine.makeVariable(name: "health", type: .integer))
		let decs = try! mainFolder.add(folder: engine.makeFolder(name: "choices"))
		try! decs.add(variable: engine.makeVariable(name: "talked_to_dave", type: .boolean))
		try! decs.add(variable: engine.makeVariable(name: "completed_task", type: .boolean))
	}
	
	
	@IBAction func onReadJSON(_ sender: NSButton) {
		let json_str = "{\"variables\":[{\"synopsis\":\"\",\"name\":\"health\",\"value\":0,\"constant\":false,\"uuid\":\"495CF612-FB2D-4AD5-8C24-B21548C40F7C\",\"type\":\"integer\",\"initialValue\":0},{\"synopsis\":\"\",\"name\":\"talked_to_dave\",\"value\":false,\"constant\":false,\"uuid\":\"B5305AB9-8D78-4B4B-BED9-AE91ED6E1961\",\"type\":\"boolean\",\"initialValue\":false},{\"synopsis\":\"\",\"name\":\"completed_task\",\"value\":false,\"constant\":false,\"uuid\":\"ED847768-5E2A-4608-B932-64CD9F1D393D\",\"type\":\"boolean\",\"initialValue\":false}],\"folders\":[{\"name\":\"story\",\"variables\":[],\"uuid\":\"A4FBEA85-4598-4F49-A9BF-D1E39FA98FDF\",\"subfolders\":[\"EFAE8730-0FD1-4C91-8D5B-189A90908430\",\"3F653B9C-8EB3-4D4D-9526-42901AB7F9AA\"]},{\"name\":\"characters\",\"variables\":[],\"uuid\":\"EFAE8730-0FD1-4C91-8D5B-189A90908430\",\"subfolders\":[\"2CCBAB44-A84E-40F8-AC89-E60F566BC818\"]},{\"name\":\"player\",\"variables\":[\"495CF612-FB2D-4AD5-8C24-B21548C40F7C\"],\"uuid\":\"2CCBAB44-A84E-40F8-AC89-E60F566BC818\",\"subfolders\":[]},{\"name\":\"choices\",\"variables\":[\"B5305AB9-8D78-4B4B-BED9-AE91ED6E1961\",\"ED847768-5E2A-4608-B932-64CD9F1D393D\"],\"uuid\":\"3F653B9C-8EB3-4D4D-9526-42901AB7F9AA\",\"subfolders\":[]}]}"
		let engine = try! Serialize.read(jsonStr: json_str)
	}
	
	@IBAction func onWriteJSON(_ sender: NSButton) {
		do {
			let str = try Serialize.write(engine: engine)
			print(str)
		} catch {
			print("Failed to convert JSON.")
		}
	}
}
