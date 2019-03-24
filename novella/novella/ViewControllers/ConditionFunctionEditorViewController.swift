//
//  ConditionFunctionEditorViewController.swift
//  novella
//
//  Created by Daniel Green on 31/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa
import Highlightr

class CFEHeader: Equatable {
	static func == (lhs: CFEHeader, rhs: CFEHeader) -> Bool {
		return lhs.name == rhs.name
	}
	
	public var name: String = ""
	init(name: String) {
		self.name = name
	}
}

class ConditionFunctionOutlineView: NSOutlineView {
	private var _menu: NSMenu!
	private var _deleteMenuItem: NSMenuItem?
	
	var onNewFunction: (() -> Void)?
	var onNewCondition: (() -> Void)?
	var onNewSelector: (() -> Void)?
	var onDeleteSelection: (() -> Void)?
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	private func setup() {
		_menu = NSMenu()
		_menu.autoenablesItems = false
		_menu.addItem(withTitle: "Add Function", action: #selector(ConditionFunctionOutlineView.onMenuNewFunction), keyEquivalent: "")
		_menu.addItem(withTitle: "Add Condition", action: #selector(ConditionFunctionOutlineView.onMenuNewCondition), keyEquivalent: "")
		_menu.addItem(withTitle: "Add Selector", action: #selector(ConditionFunctionOutlineView.onMenuNewSelector), keyEquivalent: "")
		_menu.addItem(NSMenuItem.separator())
		_deleteMenuItem = NSMenuItem(title: "Delete Selection", action: #selector(ConditionFunctionOutlineView.onMenuDeleteSelection), keyEquivalent: "")
		_deleteMenuItem!.isEnabled = false
		_menu.addItem(_deleteMenuItem!)
	}
	
	override func menu(for event: NSEvent) -> NSMenu? {
		let mousePoint = self.convert(event.locationInWindow, from: nil)
		let row = self.row(at: mousePoint)
		if row != -1 {
			self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
			_deleteMenuItem?.isEnabled = !(self.item(atRow: row) is CFEHeader) // select anything except headers
		} else {
			_deleteMenuItem?.isEnabled = false
		}
		
		return _menu
	}
	
	@objc private func onMenuNewFunction() {
		onNewFunction?()
	}
	
	@objc private func onMenuNewCondition() {
		onNewCondition?()
	}
	
	@objc private func onMenuNewSelector() {
		onNewSelector?()
	}
	
	@objc private func onMenuDeleteSelection() {
		onDeleteSelection?()
	}
}

class ConditionFunctionEditorViewController: NSViewController {
	@IBOutlet weak var _outlineView: ConditionFunctionOutlineView!
	@IBOutlet var _codeView: NSTextView!
	
	private var _document: Document? = nil
	private var _functionHeader: CFEHeader = CFEHeader(name: "Functions")
	private var _conditionHeader: CFEHeader = CFEHeader(name: "Conditions")
	private var _selectorHeader: CFEHeader = CFEHeader(name: "Selectors")
	
	private let _codeAttrStr = CodeAttributedString()
	
	private var _activeElement: Any? = nil
	
	override func viewDidAppear() {
		view.window?.level = .floating
	}
	
	override func viewDidLoad() {
		_outlineView.delegate = self
		_outlineView.dataSource = self
		_outlineView.reloadData()
		
		_outlineView.onNewFunction = {
			self.addNewFunction()
		}
		_outlineView.onNewCondition = {
			self.addNewCondition()
		}
		_outlineView.onNewSelector = {
			self.addNewSelector()
		}
		_outlineView.onDeleteSelection = {
			self.deleteSelection()
		}
		
		_codeView.isAutomaticDashSubstitutionEnabled = false
		_codeView.isAutomaticQuoteSubstitutionEnabled = false
		_codeView.delegate = self
		_codeAttrStr.language = "lua" // javascript, lua, python
		_codeAttrStr.highlightr.setTheme(to: "monokai")
		_codeAttrStr.highlightr.theme.codeFont = NSFont(name: "Courier New", size: 14.0)
		if let manager = _codeView.layoutManager {
			_codeAttrStr.addLayoutManager(manager)
		}
		_codeView.backgroundColor = _codeAttrStr.highlightr.theme.themeBackgroundColor
		_codeView.insertionPointColor = _codeView.backgroundColor.inverted()
		//print(_codeAttrStr.highlightr.availableThemes())
		//print(_codeAttrStr.highlightr.supportedLanguages())
		
		resetScript()
	}
	
	func setup(doc: Document) {
		_document = doc
	}
	
	private func addNewFunction() {
		guard let doc = _document else {
			return
		}
		let newFunc = doc.Story.makeFunction()
		_outlineView.expandItem(_functionHeader)
		_outlineView.reloadItem(_functionHeader, reloadChildren: true)
		_outlineView.selectRowIndexes(IndexSet(integer: _outlineView.row(forItem: newFunc)), byExtendingSelection: false)
	}
	
	private func addNewCondition() {
		guard let doc = _document else {
			return
		}
		let newCond = doc.Story.makeCondition()
		_outlineView.expandItem(_conditionHeader)
		_outlineView.reloadItem(_conditionHeader, reloadChildren: true)
		_outlineView.selectRowIndexes(IndexSet(integer: _outlineView.row(forItem: newCond)), byExtendingSelection: false)
	}
	
	private func addNewSelector() {
		guard let doc = _document else {
			return
		}
		let newSel = doc.Story.makeSelector()
		_outlineView.expandItem(_selectorHeader)
		_outlineView.reloadItem(_selectorHeader, reloadChildren: true)
		_outlineView.selectRowIndexes(IndexSet(integer: _outlineView.row(forItem: newSel)), byExtendingSelection: false)
	}
	
	private  func deleteSelection() {
		guard let doc = _document else {
			return
		}
		
		if let item = _outlineView.item(atRow: _outlineView.selectedRow) {
			let childIdx = _outlineView.childIndex(forItem: item)
			if -1 == childIdx {
				return
			}
			
			switch item {
			case let asFunc as NVFunction:
				doc.Story.delete(function: asFunc)
			case let asCond as NVCondition:
				doc.Story.delete(condition: asCond)
			case let asSel as NVSelector:
				doc.Story.delete(selector: asSel)
			default:
				return // something else like a header - we do not want to delete this!
			}
			
			let parent = _outlineView.parent(forItem: item)
			_outlineView.removeItems(at: IndexSet(integer: childIdx), inParent: parent, withAnimation: [.effectFade, .slideLeft])
			_outlineView.reloadItem(parent, reloadChildren: false) // if false and remove fails, will not reload it, but if true, it flickers
		}
	}
	
	private func resetScript() {
		_codeView.backgroundColor = NSColor.white
		_codeAttrStr.setAttributedString(NSAttributedString(string: ""))
		_codeView.isEditable = false
		_activeElement = nil
	}
	
	private func setupScriptFor(function: NVFunction) {
		_codeView.backgroundColor = _codeAttrStr.highlightr.theme.themeBackgroundColor
		_codeAttrStr.setAttributedString(NSAttributedString(string: function.Code))
		_codeView.isEditable = true
		_activeElement = function
	}
	
	private func setupScriptFor(condition: NVCondition) {
		_codeView.backgroundColor = _codeAttrStr.highlightr.theme.themeBackgroundColor
		_codeAttrStr.setAttributedString(NSAttributedString(string: condition.Code))
		_codeView.isEditable = true
		_activeElement = condition
	}
	
	private func setupScriptFor(selector: NVSelector) {
		_codeView.backgroundColor = _codeAttrStr.highlightr.theme.themeBackgroundColor
		_codeAttrStr.setAttributedString(NSAttributedString(string: selector.Code))
		_codeView.isEditable = true
		_activeElement = selector
	}
	
	@IBAction func onSelectionChanged(_ sender: ConditionFunctionOutlineView) {
		// select nothing
		if -1 == sender.selectedRow {
			resetScript()
			return
		}
		
		let item = sender.item(atRow: sender.selectedRow)
		
		switch item {
		case let asFunction as NVFunction:
			setupScriptFor(function: asFunction)
		case let asCondition as NVCondition:
			setupScriptFor(condition: asCondition)
		case let asSelector as NVSelector:
			setupScriptFor(selector: asSelector)
		default:
			resetScript()
		}
		return
	}
}
extension ConditionFunctionEditorViewController: NSTextViewDelegate {
	func textDidChange(_ notification: Notification) {
		if notification.object as? NSTextView == _codeView {
			switch _activeElement {
			case let asFunction as NVFunction:
				asFunction.Code = _codeView.string
			case let asCondition as NVCondition:
				asCondition.Code = _codeView.string
			case let asSelector as NVSelector:
				asSelector.Code = _codeView.string
			default:
				return
			}
			return
		}
	}
}

extension ConditionFunctionEditorViewController: NSOutlineViewDelegate {
	// custom row class
	func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
		return CustomTableRowView(frame: NSRect.zero)
	}
	
	// color even/odd rows
	func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
		rowView.backgroundColor = (row % 2 == 0) ? NSColor(named: "NVTableRowEven")! : NSColor(named: "NVTableRowOdd")!
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		var view: NSView?
		
		// handle groups
		if let asString = item as? CFEHeader {
			view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("GroupCell"), owner: self)
			(view as? NSTableCellView)?.textField?.stringValue = asString.name
			return view
		}
		
		// handle others
		view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MainCell"), owner: self)
		switch item {
		case let asFunction as NVFunction:
			(view as? NSTableCellView)?.textField?.stringValue = asFunction.Label
			
		case let asCondition as NVCondition:
			(view as? NSTableCellView)?.textField?.stringValue = asCondition.Label
			
		case let asSelector as NVSelector:
			(view as? NSTableCellView)?.textField?.stringValue = asSelector.Label
			
		default:
			(view as? NSTableCellView)?.textField?.stringValue = "ERROR"
		}
		
		return view
	}
}

extension ConditionFunctionEditorViewController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return 3 // function and condition headers
		}
		if let asString = item as? CFEHeader {
			if asString == _functionHeader {
				return _document?.Story.Functions.count ?? 0
			}
			if asString == _conditionHeader {
				return _document?.Story.Conditions.count ?? 0
			}
			if asString == _selectorHeader {
				return _document?.Story.Selectors.count ?? 0
			}
		}
		return 0
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		guard let doc = _document else {
			fatalError()
		}
		
		if item == nil {
			if index == 0 {
				return _functionHeader
			}
			if index == 1 {
				return _conditionHeader
			}
			if index == 2 {
				return _selectorHeader
			}
		}
		
		if let asString = item as? CFEHeader {
			if asString == _functionHeader {
				return doc.Story.Functions[index]
			}
			if asString == _conditionHeader {
				return doc.Story.Conditions[index]
			}
			if asString == _selectorHeader {
				return doc.Story.Selectors[index]
			}
		}
		
		fatalError()
	}
	
	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		return item is CFEHeader
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return item is CFEHeader
	}
}
