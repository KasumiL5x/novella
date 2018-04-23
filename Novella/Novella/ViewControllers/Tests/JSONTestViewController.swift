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
		let json_str = "{\"variables\":[{\"synopsis\":\"\",\"name\":\"health\",\"value\":0,\"constant\":false,\"uuid\":\"CFADD9A1-A575-4A7B-B709-D3AFFB164D0D\",\"datatype\":\"integer\",\"initialValue\":0},{\"synopsis\":\"\",\"name\":\"talked_to_dave\",\"value\":false,\"constant\":false,\"uuid\":\"B0FAE94F-BF3F-4CF7-BBF8-D0D2DC429782\",\"datatype\":\"boolean\",\"initialValue\":false},{\"synopsis\":\"\",\"name\":\"completed_task\",\"value\":false,\"constant\":false,\"uuid\":\"13256834-353D-418A-96AB-3B4276E535A4\",\"datatype\":\"boolean\",\"initialValue\":false}],\"folders\":[{\"name\":\"story\",\"variables\":[],\"uuid\":\"CF6B507C-EED5-4420-A81F-5E8C91AE9AF6\",\"subfolders\":[\"E70CD8E0-3477-4D10-91D8-2FC81A24E3C2\",\"FEF1DEC5-7BCE-4693-B865-F989D81F57F4\"]},{\"name\":\"characters\",\"variables\":[],\"uuid\":\"E70CD8E0-3477-4D10-91D8-2FC81A24E3C2\",\"subfolders\":[\"5CF91582-212B-4AD5-BE44-AE66B7DDAEE9\"]},{\"name\":\"player\",\"variables\":[\"CFADD9A1-A575-4A7B-B709-D3AFFB164D0D\"],\"uuid\":\"5CF91582-212B-4AD5-BE44-AE66B7DDAEE9\",\"subfolders\":[]},{\"name\":\"choices\",\"variables\":[\"B0FAE94F-BF3F-4CF7-BBF8-D0D2DC429782\",\"13256834-353D-418A-96AB-3B4276E535A4\"],\"uuid\":\"FEF1DEC5-7BCE-4693-B865-F989D81F57F4\",\"subfolders\":[]}]}"
		let story: Story
		do {
			story = try Story.fromJSON(str: json_str)
//			try Story.fromJSON(str: "{\"variables\":[{\"synopsis\":\"\",\"name\":\"health\",\"value\":\"stringvalue\",\"constant\":false,\"uuid\":\"495CF612-FB2D-4AD5-8C24-B21548C40F7C\",\"type\":\"integer\",\"initialValue\":0},{\"synopsis\":\"\",\"name\":\"talked_to_dave\",\"value\":false,\"constant\":false,\"uuid\":\"B5305AB9-8D78-4B4B-BED9-AE91ED6E1961\",\"type\":\"boolean\",\"initialValue\":false},{\"synopsis\":\"\",\"name\":\"completed_task\",\"value\":false,\"constant\":false,\"uuid\":\"ED847768-5E2A-4608-B932-64CD9F1D393D\",\"type\":\"boolean\",\"initialValue\":false}],\"folders\":[{\"name\":\"story\",\"variables\":[],\"uuid\":\"A4FBEA85-4598-4F49-A9BF-D1E39FA98FDF\",\"subfolders\":[\"EFAE8730-0FD1-4C91-8D5B-189A90908430\",\"3F653B9C-8EB3-4D4D-9526-42901AB7F9AA\"]},{\"name\":\"characters\",\"variables\":[],\"uuid\":\"EFAE8730-0FD1-4C91-8D5B-189A90908430\",\"subfolders\":[\"2CCBAB44-A84E-40F8-AC89-E60F566BC818\"]},{\"name\":\"player\",\"variables\":[\"495CF612-FB2D-4AD5-8C24-B21548C40F7C\"],\"uuid\":\"2CCBAB44-A84E-40F8-AC89-E60F566BC818\",\"subfolders\":[]},{\"name\":\"choices\",\"variables\":[\"B5305AB9-8D78-4B4B-BED9-AE91ED6E1961\",\"ED847768-5E2A-4608-B932-64CD9F1D393D\"],\"uuid\":\"3F653B9C-8EB3-4D4D-9526-42901AB7F9AA\",\"subfolders\":[]}]}")
//			try Story.fromJSON(str: "{\"variables\":[{\"synopsis\":\"\",\"name\":\"health\",\"value\":0,\"constant\":false,\"uuid\":\"495CF612-FB2D-4AD5-8C24-B21548C40F7C\",\"type\":\"invalid\",\"initialValue\":0},{\"synopsis\":\"\",\"name\":\"talked_to_dave\",\"value\":false,\"constant\":false,\"uuid\":\"B5305AB9-8D78-4B4B-BED9-AE91ED6E1961\",\"type\":\"boolean\",\"initialValue\":false},{\"synopsis\":\"\",\"name\":\"completed_task\",\"value\":false,\"constant\":false,\"uuid\":\"ED847768-5E2A-4608-B932-64CD9F1D393D\",\"type\":\"boolean\",\"initialValue\":false}],\"folders\":[{\"name\":\"story\",\"variables\":[],\"uuid\":\"A4FBEA85-4598-4F49-A9BF-D1E39FA98FDF\",\"subfolders\":[\"EFAE8730-0FD1-4C91-8D5B-189A90908430\",\"3F653B9C-8EB3-4D4D-9526-42901AB7F9AA\"]},{\"name\":\"characters\",\"variables\":[],\"uuid\":\"EFAE8730-0FD1-4C91-8D5B-189A90908430\",\"subfolders\":[\"2CCBAB44-A84E-40F8-AC89-E60F566BC818\"]},{\"name\":\"player\",\"variables\":[\"495CF612-FB2D-4AD5-8C24-B21548C40F7C\"],\"uuid\":\"2CCBAB44-A84E-40F8-AC89-E60F566BC818\",\"subfolders\":[]},{\"name\":\"choices\",\"variables\":[\"B5305AB9-8D78-4B4B-BED9-AE91ED6E1961\",\"ED847768-5E2A-4608-B932-64CD9F1D393D\"],\"uuid\":\"3F653B9C-8EB3-4D4D-9526-42901AB7F9AA\",\"subfolders\":[]}]}")
//			let _ = try Story.fromJSON(str: "{\"variables\":[{\"synopsis\":\"\",\"name\":\"health\",\"value\":0,\"constant\":false,\"uuid\":\"495CF612-FB2D-4AD5-8C24-B21548C40F7C\",\"type\":\"integer\",\"initialValue\":0},{\"synopsis\":\"\",\"name\":\"talked_to_dave\",\"value\":false,\"constant\":false,\"uuid\":\"B5305AB9-8D78-4B4B-BED9-AE91ED6E1961\",\"type\":\"boolean\",\"initialValue\":false},{\"synopsis\":\"\",\"name\":\"completed_task\",\"value\":false,\"constant\":false,\"uuid\":\"ED847768-5E2A-4608-B932-64CD9F1D393D\",\"type\":\"boolean\",\"initialValue\":false}]}")
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
