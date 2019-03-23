//
//  MainViewController.swift
//  novella
//
//  Created by dgreen on 10/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTableViewDelegate {
	private var _propertiesVC: PropertiesViewController? = nil
	private var _graphVC: GraphViewController? = nil
	private var _outlinerVC: OutlinerViewController? = nil
	private var _condFuncEdVC: ConditionFunctionEditorViewController? = nil
	
	override func viewWillAppear() {
		guard let doc = view.window?.windowController?.document as? Document else {
			return
		}
		
		_graphVC?.setup(doc: doc)
		_propertiesVC?.setup(doc: doc)
		
		NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.onCanvasObjectDoubleClicked), name: NSNotification.Name.nvCanvasObjectDoubleClicked, object: nil)
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == "Properties" {
			_propertiesVC = segue.destinationController as? PropertiesViewController
		}
		
		if segue.identifier == "GraphVC" {
			_graphVC = segue.destinationController as? GraphViewController
		}
		
		if segue.identifier == "OutlinerVC" {
			_outlinerVC = segue.destinationController as? OutlinerViewController
			guard let doc = view.window?.windowController?.document as? Document else {
				print("ERROR: Could not find doc when OutlinerVC segue was triggered.")
				return
			}
			_outlinerVC?.setup(doc: doc)
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
}
