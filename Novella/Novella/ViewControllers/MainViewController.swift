//
//  MainViewController.swift
//  novella
//
//  Created by dgreen on 10/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTableViewDelegate {
	private var _graphVC: GraphViewController? = nil
	private var _outlinerVC: OutlinerViewController? = nil
	private var _inspectorVC: InspectorViewController? = nil
	
	override func viewWillAppear() {
		guard let doc = view.window?.windowController?.document as? Document else {
			return
		}
		
		_graphVC?.setup(doc: doc)
		
		NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.onCanvasObjectDoubleClicked), name: NSNotification.Name.nvCanvasObjectDoubleClicked, object: nil)
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
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
		
		if segue.identifier == "InspectorVC" {
			_inspectorVC = segue.destinationController as? InspectorViewController
		}
	}
	
	@objc private func onCanvasObjectDoubleClicked(_ sender: NSNotification) {
		guard let obj = sender.userInfo?["object"] as? CanvasObject else {
			return
		}
		
		performSegue(withIdentifier: "InspectorVC", sender: nil)
		_inspectorVC?.setupFor(object: obj)
		
	}
}
