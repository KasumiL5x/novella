//
//  JSONTestViewController.swift
//  Novella
//
//  Created by Daniel Green on 18/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class JSONTestViewController: NSViewController {
	let _story: NVStory = NVStory()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		// MARK: First test story
//		// folders and variables
//		let mainFolder = try! _story.add(folder: _story.makeFolder(name: "main"))
//		let decisionVariable = try! mainFolder.add(variable: _story.makeVariable(name: "decision", type: .boolean))
//		//graphs
//		let mainGraph = try! _story.add(graph: _story.makeGraph(name: "main"))
//		// nodes
//		let dlgA = _story.makeDialog()
//		let dlgB = _story.makeDialog()
//		let dlgC = _story.makeDialog()
//		let dlgD = _story.makeDialog()
//		let dlgE = _story.makeDialog()
//		let dlgF = _story.makeDialog()
//		let dlgG = _story.makeDialog()
//		// links
//		let aToB = _story.makeLink(origin: dlgA)
//		let aToC = _story.makeLink(origin: dlgA)
//		let bToD = _story.makeLink(origin: dlgB)
//		let cToD = _story.makeLink(origin: dlgC)
//		let dBranch = _story.makeBranch(origin: dlgD) // to E and F
//		let eToG = _story.makeLink(origin: dlgE)
//		let fToG = _story.makeLink(origin: dlgF)
//		// set up links
//		aToB.Transfer.Destination = dlgB
//		aToC.Transfer.Destination = dlgC
//		bToD.Transfer.Destination = dlgD
//		cToD.Transfer.Destination = dlgD
//		dBranch.TrueTransfer.Destination = dlgE
//		dBranch.FalseTransfer.Destination = dlgF
//		eToG.Transfer.Destination = dlgG
//		fToG.Transfer.Destination = dlgG
//		// add nodes to graph
//		try! mainGraph.add(node: dlgA)
//		try! mainGraph.add(node: dlgB)
//		try! mainGraph.add(node: dlgC)
//		try! mainGraph.add(node: dlgD)
//		try! mainGraph.add(node: dlgE)
//		try! mainGraph.add(node: dlgF)
//		try! mainGraph.add(node: dlgG)
//		// add links to graph
//		try! mainGraph.add(link: aToB)
//		try! mainGraph.add(link: aToC)
//		try! mainGraph.add(link: bToD)
//		try! mainGraph.add(link: cToD)
//		try! mainGraph.add(link: dBranch)
//		try! mainGraph.add(link: eToG)
//		try! mainGraph.add(link: fToG)
//		// set entry point of graph
//		try! mainGraph.setEntry(dlgA)
//		// set content of dialog nodes
//		dlgA.Content = "This node has two parallel choices of equal value."
//		dlgB.Content = "This was choice 1."
//		dlgC.Content = "This was choice 2."
//		dlgD.Content = "This node resolves from B and C regardless of choice.  There is a branch here based on some condition."
//		dlgE.Content = "This is the true result."
//		dlgF.Content = "This is the false result."
//		dlgG.Content = "This is the final resolve from E and F regardless of chioce."
		
		
		
		// MARK: Simple story with one graph and one dialog node
//		let mainGraph = try! _story.add(graph: _story.makeGraph(name: "main"))
//		let dlgNode = try! mainGraph.add(node: _story.makeDialog()) as! Dialog
//		dlgNode._content = "Hello, this is the content."
//		dlgNode._preview = "This is preview."
//		dlgNode._directions = "Softly"
//		try! mainGraph.setEntry(entry: dlgNode)
		
//		// set up some story graph and variable content
//		let mainGraph = try! _story.add(graph: _story.makeGraph(name: "main"))
//		let mq1 = try! mainGraph.add(graph: _story.makeGraph(name: "quest1"))
//		try! mq1.add(graph: _story.makeGraph(name: "objective1"))
//		let mq2 = try! mainGraph.add(graph: _story.makeGraph(name: "quest2"))
//		try! mq2.add(graph: _story.makeGraph(name: "objective1"))
//		try! mq2.add(graph: _story.makeGraph(name: "objective2"))
//		let side = try! _story.add(graph: _story.makeGraph(name: "side"))
//		try! side.add(graph: _story.makeGraph(name: "quest1"))
//		try! side.add(graph: _story.makeGraph(name: "quest2"))
//		//
////		let mainFolder = try! _story.add(folder: _story.makeFolder(name: "story"))
////		let chars = try! mainFolder.add(folder: _story.makeFolder(name: "characters"))
////		let player = try! chars.add(folder: _story.makeFolder(name: "player"))
////		try! player.add(variable: _story.makeVariable(name: "health", type: .integer))
////		let decs = try! mainFolder.add(folder: _story.makeFolder(name: "choices"))
////		try! decs.add(variable: _story.makeVariable(name: "talked_to_dave", type: .boolean))
////		try! decs.add(variable: _story.makeVariable(name: "completed_task", type: .boolean))
//
//		// add variables (and folders) to test data types
//		let typeFolder = try! _story.add(folder: _story.makeFolder(name: "types"))
//		try! typeFolder.add(variable: _story.makeVariable(name: "booleanTest", type: .boolean))
//		try! typeFolder.add(variable: _story.makeVariable(name: "integerTest", type: .integer))
//		try! typeFolder.add(variable: _story.makeVariable(name: "doubleTest", type: .double))
//
//		// set up some dummy links
//		let linkA = _story.makeLink()
//		linkA.setOrigin(origin: mq1)
//		linkA._transfer.setDestination(dest: mq2)
//
//		let linkB = _story.makeBranch()
//		linkB.setOrigin(origin: mq1)
//		linkB._trueTransfer.setDestination(dest: mq2)
//		linkB._falseTransfer.setDestination(dest: side)
	}
	
	
	@IBAction func onReadJSON(_ sender: NSButton) {
////		let json_str = "{\"folders\":[{\"name\":\"types\",\"variables\":[\"09FE7F4E-8097-424D-8FA0-65AD60FA9474\",\"8C0492EB-EC33-43AE-9285-E76F8722A398\",\"C410EC16-C6C1-4394-A5E1-EF7B4524E54B\"],\"uuid\":\"62C5D162-26D2-40BD-AF51-D2A1DB4B9F22\",\"subfolders\":[]}],\"variables\":[{\"synopsis\":\"\",\"name\":\"booleanTest\",\"value\":false,\"constant\":false,\"uuid\":\"09FE7F4E-8097-424D-8FA0-65AD60FA9474\",\"datatype\":\"boolean\",\"initialValue\":false},{\"synopsis\":\"\",\"name\":\"integerTest\",\"value\":0,\"constant\":false,\"uuid\":\"8C0492EB-EC33-43AE-9285-E76F8722A398\",\"datatype\":\"integer\",\"initialValue\":0},{\"synopsis\":\"\",\"name\":\"doubleTest\",\"value\":0,\"constant\":false,\"uuid\":\"C410EC16-C6C1-4394-A5E1-EF7B4524E54B\",\"datatype\":\"double\",\"initialValue\":0}],\"links\":[{\"linktype\":\"link\",\"origin\":\"53E67231-3511-4C8F-95CE-139ABB3D1156\",\"uuid\":\"E010FEAA-2CA1-4EFE-946B-ADFDE0819BC1\",\"transfer\":{\"destination\":\"7297667B-C2D5-4AF4-B8BC-376CDD676D60\"}},{\"linktype\":\"branch\",\"origin\":\"53E67231-3511-4C8F-95CE-139ABB3D1156\",\"uuid\":\"36DC95A1-B187-4AA6-92C7-E3F40B6C2C71\",\"ftransfer\":{\"destination\":\"EE1F4AF3-962B-4F21-8674-D4ECED505133\"},\"ttransfer\":{\"destination\":\"7297667B-C2D5-4AF4-B8BC-376CDD676D60\"}}],\"nodes\":[],\"graphs\":[{\"name\":\"main\",\"nodes\":[],\"links\":[],\"uuid\":\"A634EC6A-192C-40CA-A886-7BF5AAC7771C\",\"subgraphs\":[\"53E67231-3511-4C8F-95CE-139ABB3D1156\",\"7297667B-C2D5-4AF4-B8BC-376CDD676D60\"],\"listeners\":[],\"exits\":[]},{\"name\":\"quest1\",\"nodes\":[],\"links\":[],\"uuid\":\"53E67231-3511-4C8F-95CE-139ABB3D1156\",\"subgraphs\":[\"CA0B5B18-D6D5-4E38-A87F-9A839A457FB8\"],\"listeners\":[],\"exits\":[]},{\"name\":\"objective1\",\"nodes\":[],\"links\":[],\"uuid\":\"CA0B5B18-D6D5-4E38-A87F-9A839A457FB8\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"quest2\",\"nodes\":[],\"links\":[],\"uuid\":\"7297667B-C2D5-4AF4-B8BC-376CDD676D60\",\"subgraphs\":[\"FD84D14E-B912-4205-9A26-99459016C1A1\",\"76FFD076-1B72-4B82-A15B-064B166E6E9C\"],\"listeners\":[],\"exits\":[]},{\"name\":\"objective1\",\"nodes\":[],\"links\":[],\"uuid\":\"FD84D14E-B912-4205-9A26-99459016C1A1\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"objective2\",\"nodes\":[],\"links\":[],\"uuid\":\"76FFD076-1B72-4B82-A15B-064B166E6E9C\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"side\",\"nodes\":[],\"links\":[],\"uuid\":\"EE1F4AF3-962B-4F21-8674-D4ECED505133\",\"subgraphs\":[\"E40679B6-6376-4A0E-ACE5-7C316BB528EC\",\"18D0ED15-B22C-4CA9-9E60-DA01902037FF\"],\"listeners\":[],\"exits\":[]},{\"name\":\"quest1\",\"nodes\":[],\"links\":[],\"uuid\":\"E40679B6-6376-4A0E-ACE5-7C316BB528EC\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]},{\"name\":\"quest2\",\"nodes\":[],\"links\":[],\"uuid\":\"18D0ED15-B22C-4CA9-9E60-DA01902037FF\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]}]}"
//		let json_str = "{\"folders\":[],\"variables\":[],\"links\":[],\"nodes\":[{\"content\":\"Hello, this is the content.\",\"uuid\":\"71CE6B3E-C2C3-4981-828E-8AB4B9DCE66E\",\"directions\":\"Softly\",\"nodetype\":\"dialog\",\"preview\":\"This is preview.\"}],\"graphs\":[{\"name\":\"main\",\"nodes\":[\"71CE6B3E-C2C3-4981-828E-8AB4B9DCE66E\"],\"links\":[],\"uuid\":\"BBA325A4-249F-48E2-A1A9-4F65E785B691\",\"subgraphs\":[],\"listeners\":[],\"exits\":[]}]}"
//		do {
//			let (story, errors) = try NVStory.fromJSON(str: json_str)
//			for e in errors {
//				print(e)
//			}
//		} catch {
//			print("oh shit")
//		}
	}
	
	@IBAction func onWriteJSON(_ sender: NSButton) {
//		do {
//			let str = try _story.toJSON()
//			print(str)
//		} catch {
//			print("Failed to convert JSON.")
//		}
	}
}
