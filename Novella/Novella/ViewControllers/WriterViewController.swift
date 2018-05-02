//
//  WriterViewController.swift
//  Novella
//
//  Created by Daniel Green on 26/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Cocoa

class WriterViewController: NSViewController {
	@IBOutlet weak var scrollView: NSScrollView!
	@IBOutlet weak var storyName: NSTextField!
	var _canvas: Canvas?
	var _story: Story?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		_canvas = Canvas(frame: NSRect(x: 0, y: 0, width: 2000, height: 2000))
		scrollView.documentView = _canvas
		scrollView.hasVerticalRuler = true
		scrollView.hasHorizontalRuler = true
		
		_story = Story()
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
			let (story, errors) = try Story.fromJSON(str: contents)
			if errors.count != 0 {
				let _ = errors.map({print($0)})
				return
			}
			_story = story
		} catch {
			print("Failed to parse JSON.")
			return
		}
		
		storyName.stringValue = _story!._name.isEmpty ? "unnamed" : _story!._name
		
		// TODO: RESET CANVAS.
		_canvas!.reset()
		
		// create canvas nodes for each dialog node
		for curr in _story!._allNodes {
			if let dlg = curr as? Dialog {
				_canvas!.makeDialogWidget(novellaDialog: dlg)
			} else {
				print("Encounterd node type that's not handled in Canvas yet (\(type(of:curr))).")
			}
		}
		
		_story?.debugPrint(global: true)
	}
	
	@IBAction func onCloseStory(_ sender: NSButton) {
		_canvas!.reset()
		_story = Story()
		storyName.stringValue = ""
	}
	
	@IBAction func onCreateDialog(_ sender: NSButton) {
		if _story == nil {
			return
		}
		
		let dialog = _story!.makeDialog()
		// hack just to test different names
		dialog._name = "dlg-\(_story!._allNodes.count-1)"
		_canvas?.makeDialogWidget(novellaDialog: dialog)
	}
}

// MARK: TouchBar
extension WriterViewController {
	
//	override func makeTouchBar() -> NSTouchBar? {
//		let touchBar = NSTouchBar()
//		touchBar.delegate = self
//		touchBar.customizationIdentifier = TouchBarID.Identifiers.Writer
//		touchBar.defaultItemIdentifiers = [TouchBarID.Items.Writer.CreateNode]
//		touchBar.customizationAllowedItemIdentifiers = [TouchBarID.Items.Writer.CreateNode]
//		touchBar.principalItemIdentifier = TouchBarID.Items.Writer.CreateNode
//		return touchBar
//	}
}

extension WriterViewController: NSTouchBarDelegate {
//	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
//		switch identifier {
//		case TouchBarID.Items.Writer.CreateNode:
//			return NSColorPickerTouchBarItem.colorPicker(withIdentifier: identifier)
//		default:
//			return nil
//		}
//	}
}
