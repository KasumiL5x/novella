//
//  JSONTestViewController.swift
//  Novella
//
//  Created by Daniel Green on 18/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class JSONTestViewController: NSViewController {
	let _story: Story = Story()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// set up some story graph and variable content
		let mainGraph = try! _story.add(graph: _story.makeGraph(name: "main"))
		let mq1 = try! mainGraph.add(graph: _story.makeGraph(name: "quest1"))
		try! mq1.add(graph: _story.makeGraph(name: "objective1"))
		let mq2 = try! mainGraph.add(graph: _story.makeGraph(name: "quest2"))
		try! mq2.add(graph: _story.makeGraph(name: "objective1"))
		try! mq2.add(graph: _story.makeGraph(name: "objective2"))
		let side = try! _story.add(graph: _story.makeGraph(name: "side"))
		try! side.add(graph: _story.makeGraph(name: "quest1"))
		try! side.add(graph: _story.makeGraph(name: "quest2"))
		//
		let mainFolder = try! _story.add(folder: _story.makeFolder(name: "story"))
		let chars = try! mainFolder.add(folder: _story.makeFolder(name: "characters"))
		let player = try! chars.add(folder: _story.makeFolder(name: "player"))
		try! player.add(variable: _story.makeVariable(name: "health", type: .integer))
		let decs = try! mainFolder.add(folder: _story.makeFolder(name: "choices"))
		try! decs.add(variable: _story.makeVariable(name: "talked_to_dave", type: .boolean))
		try! decs.add(variable: _story.makeVariable(name: "completed_task", type: .boolean))
	}
	
	
	@IBAction func onReadJSON(_ sender: NSButton) {
		let json_str = "{\"variables\":[{\"synopsis\":\"\",\"name\":\"health\",\"value\":0,\"constant\":false,\"uuid\":\"495CF612-FB2D-4AD5-8C24-B21548C40F7C\",\"type\":\"integer\",\"initialValue\":0},{\"synopsis\":\"\",\"name\":\"talked_to_dave\",\"value\":false,\"constant\":false,\"uuid\":\"B5305AB9-8D78-4B4B-BED9-AE91ED6E1961\",\"type\":\"boolean\",\"initialValue\":false},{\"synopsis\":\"\",\"name\":\"completed_task\",\"value\":false,\"constant\":false,\"uuid\":\"ED847768-5E2A-4608-B932-64CD9F1D393D\",\"type\":\"boolean\",\"initialValue\":false}],\"folders\":[{\"name\":\"story\",\"variables\":[],\"uuid\":\"A4FBEA85-4598-4F49-A9BF-D1E39FA98FDF\",\"subfolders\":[\"EFAE8730-0FD1-4C91-8D5B-189A90908430\",\"3F653B9C-8EB3-4D4D-9526-42901AB7F9AA\"]},{\"name\":\"characters\",\"variables\":[],\"uuid\":\"EFAE8730-0FD1-4C91-8D5B-189A90908430\",\"subfolders\":[\"2CCBAB44-A84E-40F8-AC89-E60F566BC818\"]},{\"name\":\"player\",\"variables\":[\"495CF612-FB2D-4AD5-8C24-B21548C40F7C\"],\"uuid\":\"2CCBAB44-A84E-40F8-AC89-E60F566BC818\",\"subfolders\":[]},{\"name\":\"choices\",\"variables\":[\"B5305AB9-8D78-4B4B-BED9-AE91ED6E1961\",\"ED847768-5E2A-4608-B932-64CD9F1D393D\"],\"uuid\":\"3F653B9C-8EB3-4D4D-9526-42901AB7F9AA\",\"subfolders\":[]}]}"
		let engine = try! Serialize.read(jsonStr: json_str)
	}
	
	@IBAction func onWriteJSON(_ sender: NSButton) {
		do {
			let str = try Serialize.write(story: _story)
			print(str)
		} catch {
			print("Failed to convert JSON.")
		}
	}
}
