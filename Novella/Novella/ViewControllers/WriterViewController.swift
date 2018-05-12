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
	
	@IBOutlet weak var propertiesView: NSView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_story = NVStory()
		
		_canvas = Canvas(frame: NSRect(x: 0, y: 0, width: 2000, height: 2000), story: _story!)
		_canvas?.setCanvasDelegate(self)
		
		scrollView.documentView = _canvas
		scrollView.hasVerticalRuler = true
		scrollView.hasHorizontalRuler = true
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
		_story = NVStory()
		storyName.stringValue = ""
		_canvas!.reset(to: _story!)
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
	
	@IBAction func onNewStory(_ sender: NSButton) {
		_story = NVStory()
		_canvas!.reset(to: _story!)
	}
	
	@IBAction func onCreateDialog(_ sender: NSButton) {
		let node = _canvas!.makeDialogWidget(novellaDialog: _story!.makeDialog())
	}
	
}


extension WriterViewController: CanvasDelegate {
	func onSelectionChanged(selection: [LinkableWidget]) {
		if selection.count != 1 {
			setupPropertiesFor(linkableWidget: nil)
		} else {
			setupPropertiesFor(linkableWidget: nil)
			setupPropertiesFor(linkableWidget: selection[0])
		}
	}
}

// properties panel stuff
extension WriterViewController: NSTextFieldDelegate {
	func setupPropertiesFor(linkableWidget: LinkableWidget?) {
		if linkableWidget == nil {
			propertiesView.subviews.removeAll()
			return
		}
		
		// handle dialog widgets
		if let asDialog = linkableWidget as? DialogWidget {
			// dialog label
			let dlgLabel = NSTextField(labelWithString: "Dialog")
			dlgLabel.translatesAutoresizingMaskIntoConstraints = false
			dlgLabel.alignment = .center
			dlgLabel.font = NSFont(name: "Arial-BoldMT", size: 20)
			dlgLabel.sizeToFit()
			propertiesView.addSubview(dlgLabel)
			propertiesView.addConstraint(NSLayoutConstraint(item: dlgLabel, attribute: .left, relatedBy: .equal, toItem: propertiesView, attribute: .left, multiplier: 1.0, constant: 0))
			propertiesView.addConstraint(NSLayoutConstraint(item: dlgLabel, attribute: .right, relatedBy: .equal, toItem: propertiesView, attribute: .right, multiplier: 1.0, constant: 0))
			propertiesView.addConstraint(NSLayoutConstraint(item: dlgLabel, attribute: .top, relatedBy: .equal, toItem: propertiesView, attribute: .top, multiplier: 1.0, constant: 15))
			propertiesView.addConstraint(NSLayoutConstraint(item: dlgLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: dlgLabel.frame.height))
			
			// name text box
			let txtName = NSTextField(string: (asDialog.Linkable as! NVDialog).Name)
			txtName.delegate = self
			txtName.translatesAutoresizingMaskIntoConstraints = false
			txtName.sizeToFit()
			txtName.placeholderString = "Name"
			propertiesView.addSubview(txtName)
			propertiesView.addConstraint(NSLayoutConstraint(item: txtName, attribute: .top, relatedBy: .equal, toItem: dlgLabel, attribute: .bottom, multiplier: 1.0, constant: 10))
			propertiesView.addConstraint(NSLayoutConstraint(item: txtName, attribute: .left, relatedBy: .equal, toItem: propertiesView, attribute: .left, multiplier: 1.0, constant: 5))
			propertiesView.addConstraint(NSLayoutConstraint(item: txtName, attribute: .right, relatedBy: .equal, toItem: propertiesView, attribute: .right, multiplier: 1.0, constant: 5))
			propertiesView.addConstraint(NSLayoutConstraint(item: txtName, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: txtName.frame.height))
			
			// preview text box
			let txtPrev = NSTextField(string: (asDialog.Linkable as! NVDialog).Preview)
			txtPrev.delegate = self
			txtPrev.translatesAutoresizingMaskIntoConstraints = false
			txtPrev.sizeToFit()
			txtPrev.placeholderString = "Preview"
			propertiesView.addSubview(txtPrev)
			propertiesView.addConstraint(NSLayoutConstraint(item: txtPrev, attribute: .top, relatedBy: .equal, toItem: txtName, attribute: .bottom, multiplier: 1.0, constant: 5))
			propertiesView.addConstraint(NSLayoutConstraint(item: txtPrev, attribute: .left, relatedBy: .equal, toItem: propertiesView, attribute: .left, multiplier: 1.0, constant: 5))
			propertiesView.addConstraint(NSLayoutConstraint(item: txtPrev, attribute: .right, relatedBy: .equal, toItem: propertiesView, attribute: .right, multiplier: 1.0, constant: 5))
			propertiesView.addConstraint(NSLayoutConstraint(item: txtPrev, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: txtPrev.frame.height))
		}
	}
	
	override func controlTextDidEndEditing(_ obj: Notification) {
		print("ended editing \(obj)")
	}
}
