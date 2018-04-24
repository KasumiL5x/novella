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
//		let mainFolder = try! _story.add(folder: _story.makeFolder(name: "story"))
//		let chars = try! mainFolder.add(folder: _story.makeFolder(name: "characters"))
//		let player = try! chars.add(folder: _story.makeFolder(name: "player"))
//		try! player.add(variable: _story.makeVariable(name: "health", type: .integer))
//		let decs = try! mainFolder.add(folder: _story.makeFolder(name: "choices"))
//		try! decs.add(variable: _story.makeVariable(name: "talked_to_dave", type: .boolean))
//		try! decs.add(variable: _story.makeVariable(name: "completed_task", type: .boolean))
		
		// add variables (and folders) to test data types
		let typeFolder = try! _story.add(folder: _story.makeFolder(name: "types"))
		try! typeFolder.add(variable: _story.makeVariable(name: "booleanTest", type: .boolean))
		try! typeFolder.add(variable: _story.makeVariable(name: "integerTest", type: .integer))
		try! typeFolder.add(variable: _story.makeVariable(name: "doubleTest", type: .double))
	}
	
	
	@IBAction func onReadJSON(_ sender: NSButton) {
		let json_str = "{\"graphs\":[{\"name\":\"main\",\"uuid\":\"76308E64-6D8E-44F1-A1ED-4AE7FB1C88C9\"},{\"name\":\"quest1\",\"uuid\":\"206D6018-77BA-42BA-88DA-186A5F5B6F99\"},{\"name\":\"objective1\",\"uuid\":\"80E7D456-CBF2-45A4-8525-E250B63B19C8\"},{\"name\":\"quest2\",\"uuid\":\"7763A30F-8881-4927-8335-5D0ED8C8F65F\"},{\"name\":\"objective1\",\"uuid\":\"A8E52020-83F8-45CC-8609-45C8FC52D1DD\"},{\"name\":\"objective2\",\"uuid\":\"803CD7EF-E234-40D6-B4E4-FA0340B08FF1\"},{\"name\":\"side\",\"uuid\":\"40B95292-B28F-4C5A-9F96-62E43FF0A4E0\"},{\"name\":\"quest1\",\"uuid\":\"B27AEB72-05CB-4778-B2AD-5B1BD69639FB\"},{\"name\":\"quest2\",\"uuid\":\"D081AB3E-5FE0-4940-870D-001E42E2CE82\"}],\"variables\":[{\"synopsis\":\"\",\"name\":\"booleanTest\",\"value\":false,\"constant\":false,\"uuid\":\"4F520B91-C4DF-4616-9603-A9A7D6053C93\",\"datatype\":\"boolean\",\"initialValue\":false},{\"synopsis\":\"\",\"name\":\"integerTest\",\"value\":0,\"constant\":false,\"uuid\":\"97CE6C4B-2337-437A-B302-C7DECBC6AEB2\",\"datatype\":\"integer\",\"initialValue\":0},{\"synopsis\":\"\",\"name\":\"doubleTest\",\"value\":0,\"constant\":false,\"uuid\":\"1C5A37F0-DCC8-450F-98F9-423030904990\",\"datatype\":\"double\",\"initialValue\":0}],\"folders\":[{\"name\":\"types\",\"variables\":[\"4F520B91-C4DF-4616-9603-A9A7D6053C93\",\"97CE6C4B-2337-437A-B302-C7DECBC6AEB2\",\"1C5A37F0-DCC8-450F-98F9-423030904990\"],\"uuid\":\"63C453C8-C7F9-4013-A888-6BA119C2DC4E\",\"subfolders\":[]}]}"
		let story: Story
		do {
			story = try Story.fromJSON(str: json_str)
		} catch {
			print("oh shit")
		}
	}
	
	@IBAction func onWriteJSON(_ sender: NSButton) {
		do {
			let str = try _story.toJSON()
			print(str)
		} catch {
			print("Failed to convert JSON.")
		}
	}
}
