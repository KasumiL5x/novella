//
//  VariableFolderViewController.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class VariableFolderTestViewController: NSViewController {
	@IBOutlet weak var outlineView: NSOutlineView!
	@IBOutlet weak var statusLabel: NSTextField!
	
	var engine = Engine()
	
//	let root = Folder(name: "root")
	var root: Folder?
	var draggedItem: Any? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		engine.createDefaults()
		
		// dummy folder structure
		root = engine.makeFolder(name: "root")
		let characters = try! root!.add(folder: engine.makeFolder(name: "characters"))
			let player = try! characters.add(folder: engine.makeFolder(name: "player"))
				try! player.add(variable: engine.makeVariable(name: "health", type: .integer))
				try! player.add(variable: engine.makeVariable(name: "strength", type: .integer))
		let locations = try! root!.add(folder: engine.makeFolder(name: "locations"))
			let cabin = try! locations.add(folder: engine.makeFolder(name: "cabin"))
				try! cabin.add(variable: engine.makeVariable(name: "found_secret", type: .boolean))
		let decisions = try! root!.add(folder: engine.makeFolder(name: "decisions"))
			let major = try! decisions.add(folder: engine.makeFolder(name: "major"))
				try! major.add(variable: engine.makeVariable(name: "solved_crime", type: .boolean))
			let minor = try! decisions.add(folder: engine.makeFolder(name: "minor"))
				try! minor.add(variable: engine.makeVariable(name: "picked_flowers", type: .boolean))
		
		outlineView.expandItem(root, expandChildren: true)
		outlineView.sizeToFit()
		outlineView.registerForDraggedTypes([.string])
	}
	
	@IBAction func onPrintTree(_ sender: NSButton) {
		let idx = outlineView.selectedRow
		if -1 == idx {
			return
		}
		let item = outlineView.item(atRow: idx)
		if let folder = item as? Folder {
			folder.debugPrint(indent: 0)
		}
	}
	
	@IBAction func onPrintPath(_ sender: NSButton) {
		let idx = outlineView.selectedRow
		if -1 == idx {
			return
		}
		let item = outlineView.item(atRow: idx)
		if let pathable = item as? Pathable {
			print(Path.fullPathTo(object: pathable))
		}
	}
	
	@IBAction func onAddFolder(_ sender: NSButton) {
		let idx = outlineView.selectedRow
		if -1 == idx {
			return
		}
		if let folder = outlineView.item(atRow: idx) as? Folder {
			do{
				let name = NSUUID().uuidString
				try folder.add(folder: engine.makeFolder(name: name))
			} catch {
				statusLabel.stringValue = "Could not add Folder to \(folder.Name) as name was taken."
			}
		}
		outlineView.reloadData()
	}
	@IBAction func onAddVariable(_ sender: NSButton) {
		let idx = outlineView.selectedRow
		if -1 == idx {
			return
		}
		if let folder = outlineView.item(atRow: idx) as? Folder {
			do{
				let name = NSUUID().uuidString
				try folder.add(variable: engine.makeVariable(name: name, type: .boolean))
			} catch {
				statusLabel.stringValue = "Could not add Variable to \(folder.Name) as name was taken."
			}
		}
		outlineView.reloadData()
	}
	
	@IBAction func onRemove(_ sender: NSButton) {
		let idx = outlineView.selectedRow
		if -1 == idx {
			return
		}
		
		let item = outlineView.item(atRow: idx)
		if let folder = item as? Folder {
			if folder._parent != nil {
				try! folder._parent!.remove(folder: folder)
			}
		}
		if let variable = item as? Variable {
			if variable._folder != nil {
				try! variable._folder?.remove(variable: variable)
			}
		}
		
		outlineView.reloadData()
	}
	
	@IBAction func onNameEdited(_ sender: NSTextField) {
		let idx = outlineView.selectedRow
		if -1 == idx {
			return
		}
		
		let newName = sender.stringValue
		let item = outlineView.item(atRow: idx)
		if let folder = item as? Folder {
			if newName == folder.Name {
				return
			}
			do { try folder.setName(name: newName) } catch {
				statusLabel.stringValue = "Could not rename Folder (\(folder.Name)->\(newName))!"
				sender.stringValue = folder.Name
			}
		}
		if let variable = item as? Variable {
			if newName == variable.Name {
				return
			}
			do { try variable.setName(name: newName) } catch {
				statusLabel.stringValue = "Could not rename Variable (\(variable.Name)->\(newName))!"
				sender.stringValue = variable.Name
			}
		}
	}
	
}

extension VariableFolderTestViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if let _ = item as? Variable {
			return 0
		}
		if let folder = item as? Folder {
			return folder._folders.count + folder._variables.count
		}
		return 1 // root
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if let folder = item as? Folder {
			if index < folder._folders.count {
				return folder._folders[index]
			}
			return folder._variables[index - folder._folders.count]
		}
		return root!
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let _ = item as? Variable {
			return false
		}
		if let folder = item as? Folder {
			return (folder._folders.count + folder._variables.count) > 0
		}
		return (root!._folders.count + root!._variables.count) > 0
	}
	
	func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
		let pb = NSPasteboardItem()
		
		var id = ""
		if let folder = item as? Folder {
			id = folder.Name
		}
		if let variable = item as? Variable {
			id = variable.Name
		}
		
		pb.setString(id, forType: .string)
		
		draggedItem = item
		
		return pb
	}
	
	func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
		// if dragging a folder
		if let sourceFolder = draggedItem as? Folder {
			if let _ = item as? Variable {
//				print("no variables allowed")
				return []
			}
			if let targetFolder = item as? Folder {
				if targetFolder == sourceFolder || targetFolder == sourceFolder._parent {
//					print("not same folder or parent please")
					return []
				}
				if sourceFolder.hasDescendantFolder(folder: targetFolder) {
//					print("cannot be a child")
					return []
				}
			}
//			print("move")
			return NSDragOperation.move
		}
		
		// if dragging a variable
		if let sourceVariable = draggedItem as? Variable {
			if let _ = item as? Variable {
//				print("no variables allowed")
				return []
			}
			if let targetFolder = item as? Folder {
				if targetFolder == sourceVariable._folder {
//					print("not same folder please")
					return []
				}
//				print("move")
				return NSDragOperation.move
			}
		}
		
//		print("oh dear")
		return []
	}
	
	func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
		
		if let targetFolder = item as? Folder {
			if let sourceFolder = draggedItem as? Folder {
				do{ try targetFolder.add(folder: sourceFolder) } catch {
					statusLabel.stringValue = "Tried to move folder but name was taken (\(sourceFolder.Name)->\(targetFolder.Name))!"
				}
			}
			if let sourceVariable = draggedItem as? Variable {
				do{ try targetFolder.add(variable: sourceVariable) } catch {
					statusLabel.stringValue = "Tried to move variable but name was taken (\(sourceVariable.Name)->\(targetFolder.Name))!"
				}
			}
		}
		
		outlineView.reloadData()
		return true
	}
}

extension VariableFolderTestViewController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSTableCellView? = nil
		
		var name = "default"
		var type = "default"
		if let variable = item as? Variable {
			name = variable.Name
			switch variable.DataType {
			case .boolean:
				type = "boolean"
			case .integer:
				type = "integer"
			}
		}
		if let folder = item as? Folder {
			name = folder.Name
			type = "folder"
		}
		
		if tableColumn?.identifier.rawValue == "NameCell" {
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: self) as? NSTableCellView
			if let textField = view?.textField {
				textField.stringValue = name
			}
		}
		if tableColumn?.identifier.rawValue == "TypeCell" {
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TypeCell"), owner: self) as? NSTableCellView
			if let textField = view?.textField {
				textField.stringValue = type
			}
		}
		
		return view
	}
}
