//
//  VariableFolderViewController.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class VariableFolderViewController: NSViewController {
	@IBOutlet weak var outlineView: NSOutlineView!
	@IBOutlet weak var statusLabel: NSTextField!
	let root = Folder(name: "root")
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// dummy folder structure
		let characters = try! root.mkdir(name: "Characters")
			let player = try! characters.mkdir(name: "Player")
				let _ = try! player.mkvar(name: "health", type: .integer)
				let _ = try! player.mkvar(name: "strength", type: .integer)
		let locations = try! characters.mkdir(name: "Locations")
			let cabin = try! locations.mkdir(name: "Cabin")
				let _ = try! cabin.mkvar(name: "FoundSecret", type: .boolean)
		let decisions = try! root.mkdir(name: "Decisions")
			let major = try! decisions.mkdir(name: "Major")
				let _ = try! major.mkvar(name: "SolvedCrime", type: .boolean)
			let minor = try! decisions.mkdir(name: "Minor")
				let _ = try! _ = minor.mkvar(name: "PickedFlowers", type: .boolean)
		
		outlineView.expandItem(root, expandChildren: true)
		outlineView.sizeToFit()
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
	
	@IBAction func onAddFolder(_ sender: NSButton) {
		let idx = outlineView.selectedRow
		if -1 == idx {
			return
		}
		if let folder = outlineView.item(atRow: idx) as? Folder {
			let name = NSUUID().uuidString
			do{ let _ = try folder.mkdir(name: name) } catch {
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
			let name = NSUUID().uuidString
			do{ let _ = try folder.mkvar(name: name, type: .boolean) } catch {
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
				do{ try folder._parent?.removeFolder(name: folder.Name) } catch {
					
				}
			}
		}
		if let variable = item as? Variable {
			if variable._folder != nil {
				try! variable._folder?.removeVariable(name: variable.Name)
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

extension VariableFolderViewController: NSOutlineViewDataSource {
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
		return root
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let _ = item as? Variable {
			return false
		}
		if let folder = item as? Folder {
			return (folder._folders.count + folder._variables.count) > 0
		}
		return (root._folders.count + root._variables.count) > 0
	}
}

extension VariableFolderViewController: NSOutlineViewDelegate {
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
