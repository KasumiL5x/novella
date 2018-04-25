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
		
		// set up some dummy links
		let linkA = _story.makeLink()
		linkA.setOrigin(origin: mq1)
		linkA._transfer.setDestination(dest: mq2)
		
		let linkB = _story.makeBranch()
		linkB.setOrigin(origin: mq1)
		linkB._trueTransfer.setDestination(dest: mq2)
		linkB._falseTransfer.setDestination(dest: side)
	}
	
	
	@IBAction func onReadJSON(_ sender: NSButton) {
		let json_str = "{\"folders\":[{\"name\":\"types\",\"variables\":[\"E0F6707A-11A9-40C5-B1AF-728A3DD6B655\",\"2DA624E5-5FB2-45E8-83CD-4F4238A37C83\",\"813792E5-5A04-4D40-8F10-C762DEDA9DAA\"],\"uuid\":\"2710A893-91AB-44B0-80CC-E5E5BFABA1A5\",\"subfolders\":[]}],\"variables\":[{\"synopsis\":\"\",\"name\":\"booleanTest\",\"value\":false,\"constant\":false,\"uuid\":\"E0F6707A-11A9-40C5-B1AF-728A3DD6B655\",\"datatype\":\"boolean\",\"initialValue\":false},{\"synopsis\":\"\",\"name\":\"integerTest\",\"value\":0,\"constant\":false,\"uuid\":\"2DA624E5-5FB2-45E8-83CD-4F4238A37C83\",\"datatype\":\"integer\",\"initialValue\":0},{\"synopsis\":\"\",\"name\":\"doubleTest\",\"value\":0,\"constant\":false,\"uuid\":\"813792E5-5A04-4D40-8F10-C762DEDA9DAA\",\"datatype\":\"double\",\"initialValue\":0}],\"links\":[{\"linktype\":\"link\",\"transfer\":{},\"uuid\":\"2728C47F-F9E9-4632-9F03-3C5CC055AA25\"},{\"linktype\":\"branch\",\"uuid\":\"23DA26AA-323C-41EA-B599-CE9EA8815431\",\"ftransfer\":{},\"ttransfer\":{}}],\"graphs\":[{\"name\":\"main\",\"nodes\":[],\"links\":[],\"uuid\":\"910E509D-2A88-4F3D-8A43-1A0B786A70D8\",\"subgraphs\":[\"E2657AD2-210F-4385-9A43-36CAE4198C96\",\"9CF06E70-536B-466C-B95D-F4514E9AD07A\"],\"listeners\":[],\"exits\":[]},{\"name\":\"quest1\",\"nodes\":[],\"links\":[],\"uuid\":\"E2657AD2-210F-4385-9A43-36CAE4198C96\",\"subgraphs\":[\"40CD911A-C042-4753-8AF5-0CEDD088FF51\"],\"listeners\":[],\"exits\":[]},{\"name\":\"objective1\",\"nodes\":[],\"links\":[],\"uuid\":\"40CD911A-C042-4753-8AF5-0CEDD088FF51\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"quest2\",\"nodes\":[],\"links\":[],\"uuid\":\"9CF06E70-536B-466C-B95D-F4514E9AD07A\",\"subgraphs\":[\"C86A1741-4D4A-42EE-879C-B539D5B1BB1A\",\"EFBF7CD3-04C7-4102-837B-D46EE6DDF1BC\"],\"listeners\":[],\"exits\":[]},{\"name\":\"objective1\",\"nodes\":[],\"links\":[],\"uuid\":\"C86A1741-4D4A-42EE-879C-B539D5B1BB1A\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"objective2\",\"nodes\":[],\"links\":[],\"uuid\":\"EFBF7CD3-04C7-4102-837B-D46EE6DDF1BC\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"side\",\"nodes\":[],\"links\":[],\"uuid\":\"C4C6E657-9D76-4A4C-B721-E76BF267D2DD\",\"subgraphs\":[\"7F32D8B2-8A0C-4591-93AC-C9ACA06D194C\",\"5C9E94E5-3434-402A-9EB2-3EE69E33B5D5\"],\"listeners\":[],\"exits\":[]},{\"name\":\"quest1\",\"nodes\":[],\"links\":[],\"uuid\":\"7F32D8B2-8A0C-4591-93AC-C9ACA06D194C\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"quest2\",\"nodes\":[],\"links\":[],\"uuid\":\"5C9E94E5-3434-402A-9EB2-3EE69E33B5D5\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]}]}"
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
