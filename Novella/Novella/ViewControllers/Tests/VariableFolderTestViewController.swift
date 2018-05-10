//
//  VariableFolderViewController.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class VariableFolderTestViewController: NSViewController {
	@IBOutlet weak var outlineView: NSOutlineView!
	@IBOutlet weak var statusLabel: NSTextField!
	
	var _story: NVStory = NVStory()
	
//	let root = Folder(name: "root")
	var root: NVFolder?
	var draggedItem: Any? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// dummy folder structure
		root = _story.makeFolder(name: "root")
		let characters = try! root!.add(folder: _story.makeFolder(name: "characters"))
			let player = try! characters.add(folder: _story.makeFolder(name: "player"))
				try! player.add(variable: _story.makeVariable(name: "health", type: .integer))
				try! player.add(variable: _story.makeVariable(name: "strength", type: .integer))
		let locations = try! root!.add(folder: _story.makeFolder(name: "locations"))
			let cabin = try! locations.add(folder: _story.makeFolder(name: "cabin"))
				try! cabin.add(variable: _story.makeVariable(name: "found_secret", type: .boolean))
		let decisions = try! root!.add(folder: _story.makeFolder(name: "decisions"))
			let major = try! decisions.add(folder: _story.makeFolder(name: "major"))
				try! major.add(variable: _story.makeVariable(name: "solved_crime", type: .boolean))
			let minor = try! decisions.add(folder: _story.makeFolder(name: "minor"))
				try! minor.add(variable: _story.makeVariable(name: "picked_flowers", type: .boolean))
		
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
		if let folder = item as? NVFolder {
			folder.debugPrint(indent: 0)
		}
	}
	
	@IBAction func onPrintPath(_ sender: NSButton) {
		let idx = outlineView.selectedRow
		if -1 == idx {
			return
		}
		let item = outlineView.item(atRow: idx)
		if let pathable = item as? NVPathable {
			print(NVPath.fullPathTo(pathable))
		}
	}
	
	@IBAction func onAddFolder(_ sender: NSButton) {
		let idx = outlineView.selectedRow
		if -1 == idx {
			return
		}
		if let folder = outlineView.item(atRow: idx) as? NVFolder {
			do{
				let name = NSUUID().uuidString
				try folder.add(folder: _story.makeFolder(name: name))
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
		if let folder = outlineView.item(atRow: idx) as? NVFolder {
			do{
				let name = NSUUID().uuidString
				try folder.add(variable: _story.makeVariable(name: name, type: .boolean))
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
		if let folder = item as? NVFolder {
			if folder.Parent != nil {
				try! folder.Parent!.remove(folder: folder)
			}
		}
		if let variable = item as? NVVariable {
			if variable.Folder != nil {
				try! variable.Folder?.remove(variable: variable)
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
		if let folder = item as? NVFolder {
			if newName == folder.Name {
				return
			}
			do { try folder.setName(newName) } catch {
				statusLabel.stringValue = "Could not rename Folder (\(folder.Name)->\(newName))!"
				sender.stringValue = folder.Name
			}
		}
		if let variable = item as? NVVariable {
			if newName == variable.Name {
				return
			}
			do { try variable.setName(newName) } catch {
				statusLabel.stringValue = "Could not rename Variable (\(variable.Name)->\(newName))!"
				sender.stringValue = variable.Name
			}
		}
	}
	
}

extension VariableFolderTestViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if let _ = item as? NVVariable {
			return 0
		}
		if let folder = item as? NVFolder {
			return folder.Folders.count + folder.Variables.count
		}
		return 1 // root
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if let folder = item as? NVFolder {
			if index < folder.Folders.count {
				return folder.Folders[index]
			}
			return folder.Variables[index - folder.Folders.count]
		}
		return root!
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let _ = item as? NVVariable {
			return false
		}
		if let folder = item as? NVFolder {
			return (folder.Folders.count + folder.Variables.count) > 0
		}
		return (root!.Folders.count + root!.Variables.count) > 0
	}
	
	func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
		let pb = NSPasteboardItem()
		
		var id = ""
		if let folder = item as? NVFolder {
			id = folder.Name
		}
		if let variable = item as? NVVariable {
			id = variable.Name
		}
		
		pb.setString(id, forType: .string)
		
		draggedItem = item
		
		return pb
	}
	
	func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
		// if dragging a folder
		if let sourceFolder = draggedItem as? NVFolder {
			if let _ = item as? NVVariable {
//				print("no variables allowed")
				return []
			}
			if let targetFolder = item as? NVFolder {
				if targetFolder == sourceFolder || targetFolder == sourceFolder.Parent {
//					print("not same folder or parent please")
					return []
				}
				if sourceFolder.hasDescendant(folder: targetFolder) {
//					print("cannot be a child")
					return []
				}
			}
//			print("move")
			return NSDragOperation.move
		}
		
		// if dragging a variable
		if let sourceVariable = draggedItem as? NVVariable {
			if let _ = item as? NVVariable {
//				print("no variables allowed")
				return []
			}
			if let targetFolder = item as? NVFolder {
				if targetFolder == sourceVariable.Folder {
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
		
		if let targetFolder = item as? NVFolder {
			if let sourceFolder = draggedItem as? NVFolder {
				do{ try targetFolder.add(folder: sourceFolder) } catch {
					statusLabel.stringValue = "Tried to move folder but name was taken (\(sourceFolder.Name)->\(targetFolder.Name))!"
				}
			}
			if let sourceVariable = draggedItem as? NVVariable {
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
		if let variable = item as? NVVariable {
			name = variable.Name
			type = variable.DataType.stringValue
		}
		if let folder = item as? NVFolder {
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
