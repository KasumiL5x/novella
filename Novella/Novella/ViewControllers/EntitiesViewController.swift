//
//  EntitiesViewController.swift
//  novella
//
//  Created by Daniel Green on 19/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class EntitiesViewController: NSViewController {
	// MARK: - Outlets
	@IBOutlet weak var _tableView: NSTableView!
	@IBOutlet weak var _imageView: CustomImageView!
	@IBOutlet weak var _entityName: NSTextField!
	@IBOutlet weak var _entitySynopsis: NSTextField!
	
	// MARK: - Properties
	var Doc: Document? {
		didSet {
			_tableView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		_tableView.delegate = self
		_tableView.dataSource = self
		_tableView.reloadData()
		
		setForEntity(nil)
	}
	
	override func viewDidAppear() {
		_tableView.reloadData()
	}
	
	@IBAction func onToolbarButton(_ sender: NSSegmentedControl) {
		guard let doc = Doc else {
			return
		}
		
		switch sender.selectedSegment {
		case 0: // add entity
			doc.Story.makeEntity()
			_tableView.reloadData()
		case 1: // remove selected
			print("NOT YET SUPPORTED")
			_tableView.reloadData()
		default:
			break
		}
	}
	
	@IBAction func onTableSelectionChanged(_ sender: NSTableView) {
		guard let doc = Doc else {
			return
		}
		
		let idx = _tableView.selectedRow
		setForEntity(idx == -1 ? nil : doc.Story.Entities[idx])
	}
	
	private func setForEntity(_ ent: NVEntity?) {
		guard let doc = Doc else {
			return
		}
		
		if let ent = ent {
			_entityName.stringValue = ent.Name
			_entitySynopsis.stringValue = ent.Synopsis
			_imageView.image = NSImage(byReferencingFile: doc.EntityImageNames[ent.ID] ?? "") ?? NSImage(named: NSImage.cautionName) // appkit handles caching
			
		} else {
			_entityName.stringValue = ""
			_entitySynopsis.stringValue = ""
			_imageView.image = NSImage(named: NSImage.userGuestName)
		}
	}
	
	@IBAction func onNameChanged(_ sender: NSTextField) {
		guard let doc = Doc else {
			return
		}
		
		let idx = _tableView.selectedRow
		if idx == -1  {
			return
		}
		
		doc.Story.Entities[idx].Name = sender.stringValue
		_tableView.reloadData(forRowIndexes: [idx], columnIndexes: [0])
	}
	
	@IBAction func onSynopsisChanged(_ sender: NSTextField) {
		guard let doc = Doc else {
			return
		}
		
		let idx = _tableView.selectedRow
		if idx == -1 {
			return
		}
		
		doc.Story.Entities[idx].Synopsis = sender.stringValue
	}
	
	@IBAction func onImageViewChanged(_ sender: CustomImageView) {
		guard let doc = Doc else {
			return
		}
		
		let idx = _tableView.selectedRow
		if idx == -1 {
			return
		}
		
		// test load the image
		if let fn = sender.Filename, let _ = NSImage(byReferencingFile: fn) {
			doc.EntityImageNames[doc.Story.Entities[idx].ID] = fn
		} else {
			// reset it
			sender.image = nil
		}
		
		_tableView.reloadData(forRowIndexes: [idx], columnIndexes: [0])
	}
}

extension EntitiesViewController: NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		return VariablesTableRowView(frame: NSRect.zero) // reuse variables for consistency
	}
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return Doc?.Story.Entities.count ?? 0
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		var view: NSView?
		
		let item = Doc!.Story.Entities[row]
		
		view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "EntityCell"), owner: self) as? NSTableCellView
		(view as? NSTableCellView)?.textField?.stringValue = Doc!.Story.Entities[row].Name
		(view as? NSTableCellView)?.imageView?.image = NSImage(byReferencingFile: Doc!.EntityImageNames[item.ID] ?? "") ?? NSImage(named: NSImage.cautionName) // appkit handles caching
		
		return view
	}
}

extension EntitiesViewController: NSTableViewDataSource {
	
}
