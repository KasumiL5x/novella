//
//  EntityTabViewController.swift
//  Novella
//
//  Created by Daniel Green on 26/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class EntityTabViewController: NSViewController {
	// MARK: - Outlets -
	@IBOutlet private weak var _tableView: NSTableView!
	@IBOutlet private weak var _nameLabel: NSTextField!
	@IBOutlet private weak var _imageView: CustomImageView!
	
	// MARK: - Variables -
	private var _document: NovellaDocument?
	
	// MARK: - Functions -
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_tableView.delegate = self
		_tableView.dataSource = self
		_tableView.reloadData()
	}
	
	func setup(doc: NovellaDocument) {
		self._document = doc
		doc.Manager.addDelegate(self)
		
		_tableView.reloadData()
	}
	
	// MARK: - Interface Callbacks -
	@IBAction func onAddEntity(_ sender: NSButton) {
		if let manager = _document?.Manager {
			manager.makeEntity(name: NSUUID().uuidString)
		}
		_tableView.reloadData()
	}
	
	@IBAction func onRemoveEntity(_ sender: NSButton) {
		if let manager = _document?.Manager {
			if _tableView.selectedRow != -1 {
				let item = manager.Entities[_tableView.selectedRow]
				item.trash()
			}
		}
		
		_tableView.reloadData()
	}
	
	@IBAction func onTableSelectionChanged(_ sender: NSTableView) {
		let selectedRow = sender.selectedRow
		if selectedRow == -1 {
			_nameLabel.stringValue = ""
			_imageView.image = nil
			return
		}
		
		let entity = _document!.Manager.Entities[selectedRow]
		_nameLabel.stringValue = entity.Name
		_imageView.image = entity.CachedImage
	}
	
	@IBAction func onImageViewChanged(_ sender: CustomImageView) {
		let selectedRow = _tableView.selectedRow
		if selectedRow == -1 {
			return
		}
		let entity = _document!.Manager.Entities[selectedRow]
		entity.ImageName = sender.Filename ?? ""
	}
}

// MARK: - NSTableViewDelegate -
extension EntityTabViewController: NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		var view: NSView?
		
		guard let item = _document?.Manager.Entities[row] else {
			return nil
		}
		
		
		switch tableColumn?.identifier.rawValue {
		case "NameColumn":
			view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameTextCell"), owner: self) as? NSTableCellView
			(view as! NSTableCellView).textField?.stringValue = item.InTrash ? ("🗑" + item.Name) : item.Name
			
		default:
			break
		}
		
		return view
	}
}

// MARK: - NSTableViewDataSource -
extension EntityTabViewController: NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		guard let doc = _document else {
			return 0
		}
		return doc.Manager.Entities.count
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		guard let doc = _document else {
			return nil
		}
		return doc.Manager.Entities[row]
	}
}

// MARK: - NVStoryDelegate -
extension EntityTabViewController: NVStoryDelegate {
	func onStoryMakeEntity(entity: NVEntity) {
		_tableView.reloadData()
	}
	func onStoryDeleteEntity(entity: NVEntity) {
		_tableView.reloadData()
	}
}
