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
		let json_str = "{\"graphs\":[{\"name\":\"main\",\"nodes\":[],\"links\":[],\"uuid\":\"CEF51DDE-EACE-4BA3-826A-C59B7C1C2825\",\"subgraphs\":[\"ED663D61-9C65-42C4-98BD-AE0064380BF2\",\"61D0D15A-E4DC-4215-81CC-54577B49690D\"],\"listeners\":[],\"exits\":[]},{\"name\":\"quest1\",\"nodes\":[],\"links\":[],\"uuid\":\"ED663D61-9C65-42C4-98BD-AE0064380BF2\",\"subgraphs\":[\"DB52A8C9-B305-4603-82E6-AF3BBC35B69B\"],\"listeners\":[],\"exits\":[]},{\"name\":\"objective1\",\"nodes\":[],\"links\":[],\"uuid\":\"DB52A8C9-B305-4603-82E6-AF3BBC35B69B\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"quest2\",\"nodes\":[],\"links\":[],\"uuid\":\"61D0D15A-E4DC-4215-81CC-54577B49690D\",\"subgraphs\":[\"09FFC7CB-3892-4DB4-A4E1-2820BC320C24\",\"DE8AEEC3-908F-4E97-85BC-62A43B1FF833\"],\"listeners\":[],\"exits\":[]},{\"name\":\"objective1\",\"nodes\":[],\"links\":[],\"uuid\":\"09FFC7CB-3892-4DB4-A4E1-2820BC320C24\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"objective2\",\"nodes\":[],\"links\":[],\"uuid\":\"DE8AEEC3-908F-4E97-85BC-62A43B1FF833\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"side\",\"nodes\":[],\"links\":[],\"uuid\":\"3998BA90-A7C7-43D7-9C09-C1288E42871E\",\"subgraphs\":[\"2BB4ABB0-0A15-428F-99A3-5795050A3468\",\"AC2E4485-CC03-4712-8BB2-D560845E7630\"],\"listeners\":[],\"exits\":[]},{\"name\":\"quest1\",\"nodes\":[],\"links\":[],\"uuid\":\"2BB4ABB0-0A15-428F-99A3-5795050A3468\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"quest2\",\"nodes\":[],\"links\":[],\"uuid\":\"AC2E4485-CC03-4712-8BB2-D560845E7630\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]}],\"variables\":[{\"synopsis\":\"\",\"name\":\"booleanTest\",\"value\":false,\"constant\":false,\"uuid\":\"BA62C9D7-5E1B-47A1-AC13-8FEB8D8ADF29\",\"datatype\":\"boolean\",\"initialValue\":false},{\"synopsis\":\"\",\"name\":\"integerTest\",\"value\":0,\"constant\":false,\"uuid\":\"1B3B2E66-35A4-47E9-AA51-7B38AC5BB160\",\"datatype\":\"integer\",\"initialValue\":0},{\"synopsis\":\"\",\"name\":\"doubleTest\",\"value\":0,\"constant\":false,\"uuid\":\"2FF24E26-B43D-4111-9436-EF5202107573\",\"datatype\":\"double\",\"initialValue\":0}],\"folders\":[{\"name\":\"types\",\"variables\":[\"BA62C9D7-5E1B-47A1-AC13-8FEB8D8ADF29\",\"1B3B2E66-35A4-47E9-AA51-7B38AC5BB160\",\"2FF24E26-B43D-4111-9436-EF5202107573\"],\"uuid\":\"1DBF2FE7-237D-4E3F-8A3C-7D7060F04511\",\"subfolders\":[]}]}"
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
