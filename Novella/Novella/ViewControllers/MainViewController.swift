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
	
	override func viewWillAppear() {
		guard let doc = view.window?.windowController?.document as? Document else {
			return
		}
		
		_graphVC?.setup(doc: doc)
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == "GraphVC" {
			_graphVC = segue.destinationController as? GraphViewController
		}
		
		if segue.identifier == "OutlinerVC" {
			_outlinerVC = segue.destinationController as? OutlinerViewController
		}
	}
}
