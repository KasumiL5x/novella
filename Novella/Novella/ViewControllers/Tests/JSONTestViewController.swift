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
	}
	
	
	@IBAction func onReadJSON(_ sender: NSButton) {
		let json_str = "{\"folders\":[{\"name\":\"types\",\"variables\":[\"8161ACAE-72FE-4F3E-9C7B-C6733B0BFD1B\",\"CD99DE2B-8ED6-4191-83F6-2A58C4BEBAEC\",\"62B50E7C-96FD-4F70-BA62-45160A7788F5\"],\"uuid\":\"A04D5AE1-3B67-420E-871F-D5A3322077F4\",\"subfolders\":[]}],\"variables\":[{\"synopsis\":\"\",\"name\":\"booleanTest\",\"value\":false,\"constant\":false,\"uuid\":\"8161ACAE-72FE-4F3E-9C7B-C6733B0BFD1B\",\"datatype\":\"boolean\",\"initialValue\":false},{\"synopsis\":\"\",\"name\":\"integerTest\",\"value\":0,\"constant\":false,\"uuid\":\"CD99DE2B-8ED6-4191-83F6-2A58C4BEBAEC\",\"datatype\":\"integer\",\"initialValue\":0},{\"synopsis\":\"\",\"name\":\"doubleTest\",\"value\":0,\"constant\":false,\"uuid\":\"62B50E7C-96FD-4F70-BA62-45160A7788F5\",\"datatype\":\"double\",\"initialValue\":0}],\"links\":[{\"linktype\":\"link\",\"uuid\":\"48EFD4B6-A59C-4F73-BC65-168872323E32\"}],\"graphs\":[{\"name\":\"main\",\"nodes\":[],\"links\":[],\"uuid\":\"7F66D560-27BB-472C-BB7C-A4BBCFA22A77\",\"subgraphs\":[\"9FE55E51-D21B-4685-9244-1546DEEBBD8F\",\"5D1D580E-0AF6-4B99-B275-0FB0E48F3D09\"],\"listeners\":[],\"exits\":[]},{\"name\":\"quest1\",\"nodes\":[],\"links\":[],\"uuid\":\"9FE55E51-D21B-4685-9244-1546DEEBBD8F\",\"subgraphs\":[\"5D3C6D53-F27B-4ADE-B589-6D8B11D90B9F\"],\"listeners\":[],\"exits\":[]},{\"name\":\"objective1\",\"nodes\":[],\"links\":[],\"uuid\":\"5D3C6D53-F27B-4ADE-B589-6D8B11D90B9F\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"quest2\",\"nodes\":[],\"links\":[],\"uuid\":\"5D1D580E-0AF6-4B99-B275-0FB0E48F3D09\",\"subgraphs\":[\"633B77A0-B6E9-4859-B054-90ED0D4D9DBE\",\"8AFFAE1F-0735-416E-9247-3BD56157D68B\"],\"listeners\":[],\"exits\":[]},{\"name\":\"objective1\",\"nodes\":[],\"links\":[],\"uuid\":\"633B77A0-B6E9-4859-B054-90ED0D4D9DBE\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"objective2\",\"nodes\":[],\"links\":[],\"uuid\":\"8AFFAE1F-0735-416E-9247-3BD56157D68B\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"side\",\"nodes\":[],\"links\":[],\"uuid\":\"92818D15-A603-4ADE-8CDF-F9299AC17617\",\"subgraphs\":[\"E829FCF1-6971-4A0B-B2DD-3399B79BF6D3\",\"73FB3490-FA40-462D-AFC1-A2FBF2D94948\"],\"listeners\":[],\"exits\":[]},{\"name\":\"quest1\",\"nodes\":[],\"links\":[],\"uuid\":\"E829FCF1-6971-4A0B-B2DD-3399B79BF6D3\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"quest2\",\"nodes\":[],\"links\":[],\"uuid\":\"73FB3490-FA40-462D-AFC1-A2FBF2D94948\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]}]}"
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
