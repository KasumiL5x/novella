//
//  WriterViewController.swift
//  Novella
//
//  Created by Daniel Green on 26/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa
import NovellaModel

class WriterViewController: NSViewController {
	@IBOutlet weak var scrollView: NSScrollView!
	@IBOutlet weak var storyName: NSTextField!
	var _canvas: Canvas?
	var _story: NVStory?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_canvas = Canvas(frame: NSRect(x: 0, y: 0, width: 2000, height: 2000))
		scrollView.documentView = _canvas
		scrollView.hasVerticalRuler = true
		scrollView.hasHorizontalRuler = true
		
		_story = NVStory()
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		// https://stackoverflow.com/questions/42342231/how-to-show-touch-bar-in-a-viewcontroller
		self.view.window?.unbind(NSBindingName(rawValue: #keyPath(touchBar)))
		self.view.window?.bind(NSBindingName(rawValue: #keyPath(touchBar)), to: self, withKeyPath: #keyPath(touchBar), options: nil)
	}
	deinit {
		self.view.window?.unbind(NSBindingName(rawValue: #keyPath(touchBar)))
	}
	
	@IBAction func onOpenStory(_ sender: NSButton) {
		// open file
		let ofd = NSOpenPanel()
		ofd.title = "Select Novella JSON."
		ofd.canChooseDirectories = false
		ofd.canChooseFiles = true
		ofd.allowsMultipleSelection = false
		ofd.allowedFileTypes = ["json"]
		if ofd.runModal() != NSApplication.ModalResponse.OK {
			print("User cancelled open.")
			return
		}
		
		// read file contents
		let contents: String
		do {
			contents = try String(contentsOf: ofd.url!)
		}
		catch {
			print("Failed to read file.")
			return
		}
		
		do {
			let (story, errors) = try NVStory.fromJSON(str: contents)
			if errors.count != 0 {
				let _ = errors.map({print($0)})
				return
			}
			_story = story
		} catch {
			print("Failed to parse JSON.")
			return
		}
		
		storyName.stringValue = _story!.Name.isEmpty ? "unnamed" : _story!.Name
		
		_canvas!.loadFrom(story: _story!)
	}
	
	@IBAction func onCloseStory(_ sender: NSButton) {
		_canvas!.reset()
		_story = NVStory()
		storyName.stringValue = ""
	}
	
	@IBAction func onSaveStory(_ sender: NSButton) {
		let sfd = NSSavePanel()
		sfd.title = "Save Novella JSON."
		sfd.canCreateDirectories = true
		sfd.showsHiddenFiles = true
		sfd.isExtensionHidden = false
		sfd.allowedFileTypes = ["json"]
		sfd.allowsOtherFileTypes = false
		sfd.showsTagField = false
		if sfd.runModal() != .OK {
			print("User cancelled save.")
			return
		}
		
		// convert the story to JSON
		let json: String
		do {
			json = try _story!.toJSON()
		} catch {
			print("Failed to convert Story to JSON.")
			return
		}
		
		// write json to file
		do {
			try json.write(to: sfd.url!, atomically: true, encoding: .utf8)
		} catch {
			print("Failed to write JSON to file.")
			return
		}
		
		print("Successfully written JSON to file.")
	}
	
	@IBAction func onUndo(_ sender: NSButton) {
		_canvas!.undo()
	}
	
	@IBAction func onRedo(_ sender: NSButtonCell) {
		_canvas!.redo()
	}
}
