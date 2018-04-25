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
		let json_str = "{\"folders\":[{\"name\":\"types\",\"variables\":[\"0BC99705-7AA0-49DB-8ECE-C5AAAC843E5D\",\"A74366DD-863E-4894-B74D-E78B96173CF8\",\"E579362B-C1BE-4F17-BF0B-FC88C1A55631\"],\"uuid\":\"89192F6F-E26C-466F-A8F0-D870A4FD12DC\",\"subfolders\":[]}],\"variables\":[{\"synopsis\":\"\",\"name\":\"booleanTest\",\"value\":false,\"constant\":false,\"uuid\":\"0BC99705-7AA0-49DB-8ECE-C5AAAC843E5D\",\"datatype\":\"boolean\",\"initialValue\":false},{\"synopsis\":\"\",\"name\":\"integerTest\",\"value\":0,\"constant\":false,\"uuid\":\"A74366DD-863E-4894-B74D-E78B96173CF8\",\"datatype\":\"integer\",\"initialValue\":0},{\"synopsis\":\"\",\"name\":\"doubleTest\",\"value\":0,\"constant\":false,\"uuid\":\"E579362B-C1BE-4F17-BF0B-FC88C1A55631\",\"datatype\":\"double\",\"initialValue\":0}],\"links\":[{\"linktype\":\"link\",\"origin\":\"02F5F577-11B2-4CB4-A971-22C1041E5FBB\",\"uuid\":\"A17BC91B-58D0-4114-A0F6-75C0B1E650C7\",\"transfer\":{\"destination\":\"A150495C-664E-43AC-A38C-BCF04F2704DF\"}},{\"linktype\":\"branch\",\"origin\":\"02F5F577-11B2-4CB4-A971-22C1041E5FBB\",\"uuid\":\"D9878699-E060-4C8D-8F5B-2D84D5CFC2A7\",\"ftransfer\":{\"destination\":\"ADEAB18D-8744-4091-9B99-CF5E36740EA9\"},\"ttransfer\":{\"destination\":\"A150495C-664E-43AC-A38C-BCF04F2704DF\"}}],\"graphs\":[{\"name\":\"main\",\"nodes\":[],\"links\":[],\"uuid\":\"CFC998D6-0801-4ABC-95EA-642D367CEFBD\",\"subgraphs\":[\"02F5F577-11B2-4CB4-A971-22C1041E5FBB\",\"A150495C-664E-43AC-A38C-BCF04F2704DF\"],\"listeners\":[],\"exits\":[]},{\"name\":\"quest1\",\"nodes\":[],\"links\":[],\"uuid\":\"02F5F577-11B2-4CB4-A971-22C1041E5FBB\",\"subgraphs\":[\"104EC242-6A8A-4F23-BE2E-A7C7F12E7D1A\"],\"listeners\":[],\"exits\":[]},{\"name\":\"objective1\",\"nodes\":[],\"links\":[],\"uuid\":\"104EC242-6A8A-4F23-BE2E-A7C7F12E7D1A\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"quest2\",\"nodes\":[],\"links\":[],\"uuid\":\"A150495C-664E-43AC-A38C-BCF04F2704DF\",\"subgraphs\":[\"91E9BBC2-EDC6-4D9C-BD19-2DF0BEC90449\",\"5C0BF307-62E6-4193-97D6-B2D67E7940FD\"],\"listeners\":[],\"exits\":[]},{\"name\":\"objective1\",\"nodes\":[],\"links\":[],\"uuid\":\"91E9BBC2-EDC6-4D9C-BD19-2DF0BEC90449\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"objective2\",\"nodes\":[],\"links\":[],\"uuid\":\"5C0BF307-62E6-4193-97D6-B2D67E7940FD\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"side\",\"nodes\":[],\"links\":[],\"uuid\":\"ADEAB18D-8744-4091-9B99-CF5E36740EA9\",\"subgraphs\":[\"DB642DA9-5BA7-4559-99FB-4FD26F9D2979\",\"3FD5CF1B-AAEC-4C60-A036-F74CB22D34F5\"],\"listeners\":[],\"exits\":[]},{\"name\":\"quest1\",\"nodes\":[],\"links\":[],\"uuid\":\"DB642DA9-5BA7-4559-99FB-4FD26F9D2979\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"quest2\",\"nodes\":[],\"links\":[],\"uuid\":\"3FD5CF1B-AAEC-4C60-A036-F74CB22D34F5\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]}]}"
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
