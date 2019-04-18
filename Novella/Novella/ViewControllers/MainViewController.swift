//
//  MainViewController.swift
//  novella
//
//  Created by dgreen on 10/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTableViewDelegate {
	@IBOutlet weak private var _splitView: NSSplitView!
	
	private var _variablesVC: VariablesEditorViewController? = nil
	private var _graphVC: GraphViewController? = nil
	private var _outlinerVC: OutlinerViewController? = nil
	private var _condFuncEdVC: ConditionFunctionEditorViewController? = nil
	private var _entitiesEditorVC: EntitiesEditorViewController? = nil
	
	override func viewWillAppear() {
		guard let doc = view.window?.windowController?.document as? Document else {
			return
		}
		
		_splitView.delegate = self
		
		_outlinerVC?.setup(doc: doc)
		_graphVC?.setup(doc: doc)
		
		NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.onCanvasObjectDoubleClicked), name: NSNotification.Name.nvCanvasObjectDoubleClicked, object: nil)
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == "EntitiesEditor" {
			_entitiesEditorVC = segue.destinationController as? EntitiesEditorViewController
			guard let doc = view.window?.windowController?.document as? Document else {
				print("ERROR: Could not find doc when EntitiesEditorViewController segue was triggered.")
				return
			}
			_entitiesEditorVC?.setup(doc: doc)
		}
		
		if segue.identifier == "VariablesEditor" {
			_variablesVC = segue.destinationController as? VariablesEditorViewController
			guard let doc = view.window?.windowController?.document as? Document else {
				print("ERROR: Could not find doc when VariablesEditorViewController segue was triggered.")
				return
			}
			_variablesVC?.setup(doc: doc)
		}
		
		if segue.identifier == "GraphVC" {
			_graphVC = segue.destinationController as? GraphViewController
		}
		
		if segue.identifier == "OutlinerVC" {
			_outlinerVC = segue.destinationController as? OutlinerViewController
		}
		
		if segue.identifier == "ConditionFunctionEditorVC" {
			_condFuncEdVC = segue.destinationController as? ConditionFunctionEditorViewController
			guard let doc = view.window?.windowController?.document as? Document else {
				print("ERROR: Could not find doc when ConditionFunctionEditorVC segue was triggered.")
				return
			}
			_condFuncEdVC?.setup(doc: doc)
		}
	}
	
	@objc private func onCanvasObjectDoubleClicked(_ sender: NSNotification) {
		guard let obj = sender.userInfo?["object"] as? CanvasObject else {
			return
		}
		
		print("Double clicked \(obj)!")
	}
	
	func exportJSON() {
		guard let doc = view.window?.windowController?.document as? Document else {
			print("ERROR: Could not find doc when exporting to JSON.")
			return
		}
		
		let savePanel = NSSavePanel()
		savePanel.title = "Export JSON"
		savePanel.message = "Please choose a file to export JSON to."
		savePanel.allowedFileTypes = ["json"]
		savePanel.isExtensionHidden = false
		savePanel.canSelectHiddenExtension = true
		if savePanel.runModal() != NSApplication.ModalResponse.OK {
			return
		}
		
		guard let fileURL = savePanel.url else {
			print("ERROR: Could not open URL when exporting to JSON.")
			return
		}
		
		let jsonStr = doc.Story.toJSON()
		if jsonStr.isEmpty {
			print("ERROR: Tried to export to JSON but the resulting string was empty.")
			return
		}
		
		do {
			try jsonStr.write(to: fileURL, atomically: false, encoding: .utf8)
		} catch {
			print("ERROR: Failed to write JSON to file (\(error)).")
		}
		
		// yay!
		let alert = NSAlert()
		alert.messageText = "Export to JSON"
		alert.informativeText = "Successfully exported JSON to \(fileURL.absoluteString)"
		alert.alertStyle = .informational
		alert.addButton(withTitle: "OK")
		alert.runModal()
	}
	
	@IBAction func onDebug(_ sender: NSButton) {
		guard let doc = view.window?.windowController?.document as? Document else {
			print("ERROR: Could not find doc when trying to use debug button.")
			return
		}
		doc.Story.debugPrint()
	}
}

extension MainViewController: NSSplitViewDelegate {
	// Just FYI, NSSplitView now stores its subviews as all actual child views followed by all dividers.
	// For example, with 3 children, it would have 3 NSView children followed by 2 divider (derivative of NSView) children.
	
	func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
		// only the first and last ones
		return (subview == splitView.subviews[0]) || (subview == splitView.subviews[2])
	}
	
	func splitView(_ splitView: NSSplitView, shouldCollapseSubview subview: NSView, forDoubleClickOnDividerAt dividerIndex: Int) -> Bool {
		return true
	}
	
	func splitView(_ splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
		// constrain size of first panel
		if dividerIndex == 0 {
			return proposedMinimumPosition + 200.0
		}
		return proposedMinimumPosition
	}
	
	func splitView(_ splitView: NSSplitView, constrainMaxCoordinate proposedMaximumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
		// constrain size of last panel
		if dividerIndex == 1 {
			return proposedMaximumPosition - 200.0
		}
		return proposedMaximumPosition
	}
}
