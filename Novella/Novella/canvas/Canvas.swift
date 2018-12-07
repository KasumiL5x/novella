//
//  Canvas.swift
//  novella
//
//  Created by dgreen on 06/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class Canvas: NSView {
	static let DEFAULT_SIZE: CGFloat = 600000.0
	
	var didSetupGroup: ((NVGroup) -> Void)?
	var didSetupBeat: ((NVBeat) -> Void)?
	
	private(set) var Doc: Document
	private(set) var MappedGroup: NVGroup?
	private(set) var MappedBeat: NVBeat?
	private let _background: CanvasBackground
	private let _marquee: CanvasMarquee
	private var _allObjects: [CanvasObject]
	private(set) var Selection: CanvasSelection
	private var _contextMenu: NSMenu
	private let _addGroupMenuItem: NSMenuItem
	private let _addBeatMenuItem: NSMenuItem
	private let _addEventMenuItem: NSMenuItem
	private let _surfaceMenuItem: NSMenuItem
	
	init(doc: Document) {
		self.Doc = doc
		self.MappedGroup = nil
		self.MappedBeat = nil
		let initialFrame = NSMakeRect(0, 0, Canvas.DEFAULT_SIZE, Canvas.DEFAULT_SIZE)
		self._background = CanvasBackground(frame: initialFrame)
		self._marquee = CanvasMarquee(frame: initialFrame)
		self._allObjects = []
		self.Selection = CanvasSelection()
		self._contextMenu = NSMenu()
		self._addGroupMenuItem = NSMenuItem(title: "Group", action: #selector(Canvas.onContextAddGroup), keyEquivalent: "")
		self._addBeatMenuItem = NSMenuItem(title: "Beat", action: #selector(Canvas.onContextAddBeat), keyEquivalent: "")
		self._addEventMenuItem = NSMenuItem(title: "Event", action: #selector(Canvas.onContextAddEvent), keyEquivalent: "")
		self._surfaceMenuItem = NSMenuItem(title: "Surface", action: #selector(Canvas.onContextSurface), keyEquivalent: "")
		super.init(frame: initialFrame)
		
		wantsLayer = true
		
		let pan = NSPanGestureRecognizer(target: self, action: #selector(Canvas.onPan))
		pan.buttonMask = 0x1
		addGestureRecognizer(pan)
		
		let ctx = NSClickGestureRecognizer(target: self, action: #selector(Canvas.onContext))
		ctx.buttonMask = 0x2
		addGestureRecognizer(ctx)
		
		let addMenu = NSMenu()
		addMenu.autoenablesItems = false
		addMenu.addItem(_addGroupMenuItem)
		addMenu.addItem(_addBeatMenuItem)
		addMenu.addItem(_addEventMenuItem)
		let addMenuItem = NSMenuItem()
		addMenuItem.title = "Add..."
		addMenuItem.submenu = addMenu
		_contextMenu.addItem(addMenuItem)
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(_surfaceMenuItem)
		_contextMenu.autoenablesItems = false
		
		doc.Story.Delegates.append(self)
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	func setupFor(group: NVGroup) {
		MappedGroup = group
		MappedBeat = nil
		
		_addGroupMenuItem.isEnabled = true
		_addBeatMenuItem.isEnabled = true
		_addEventMenuItem.isEnabled = false
		_surfaceMenuItem.isEnabled = group.Parent != nil
		
		Selection.clear()
		
		subviews.removeAll()
		addSubview(_background)
		addSubview(_marquee)
		
		// add all child groups
		for child in group.Groups {
			makeGroup(nvGroup: child, at: Doc.Positions[child.UUID] ?? centerPoint())
		}
		// add all child beats
		for child in group.Beats {
			makeBeat(nvBeat: child, at: Doc.Positions[child.UUID] ?? centerPoint())
		}
		
		didSetupGroup?(group)
	}
	
	func setupFor(beat: NVBeat) {
		MappedBeat = beat
		MappedGroup = nil
		
		_addGroupMenuItem.isEnabled = false
		_addBeatMenuItem.isEnabled = false
		_addEventMenuItem.isEnabled = false
		_surfaceMenuItem.isEnabled = beat.Parent != nil
		
		Selection.clear()
		
		subviews.removeAll()
		addSubview(_background)
		addSubview(_marquee)
		
		// add all child events
		for child in beat.Events {
			makeEvent(nvEvent: child, at: Doc.Positions[child.UUID] ?? centerPoint())
		}
		
		didSetupBeat?(beat)
	}
	
	override func mouseDown(with event: NSEvent) {  // this is the default mousedown w/o any gestures
		Selection.clear()
	}
	
	private func objectIn(obj: CanvasObject, rect: NSRect) -> Bool {
		return NSIntersectsRect(obj.frame, rect)
	}
	private func allObjectsIn(rect: NSRect) -> [CanvasObject] {
		var objs: [CanvasObject] = []
		_allObjects.forEach { (obj) in
			if objectIn(obj: obj, rect: _marquee.Region) {
				objs.append(obj)
			}
		}
		return objs
	}
	
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			_marquee.Origin = gesture.location(in: self)
			_marquee.InMarquee = true
			
		case .changed:
			if _marquee.InMarquee {
				_marquee.End = gesture.location(in: self)
			}
			
		case .cancelled, .ended:
			if _marquee.InMarquee {
				let append = NSApp.currentEvent?.modifierFlags.contains(.shift) ?? false
				Selection.select(allObjectsIn(rect: _marquee.Region), append: append)
				
				_marquee.InMarquee = false
			}
			
		default:
			break
		}
	}
	
	@objc private func onContext(gesture: NSClickGestureRecognizer) {
		if MappedGroup != nil || MappedBeat != nil {
			// must be set up to show context menu
			NSMenu.popUpContextMenu(_contextMenu, with: NSApp.currentEvent!, for: self)
		}
	}
	
	@objc private func onContextAddGroup() {
		if let mappedGroup = MappedGroup {
			let newGroup = Doc.Story.makeGroup()
			mappedGroup.add(group: newGroup)
		}
	}
	
	@objc private func onContextAddBeat() {
		if let mappedGroup = MappedGroup {
			let newBeat = Doc.Story.makeBeat()
			mappedGroup.add(beat: newBeat)
		}
	}
	
	@objc private func onContextAddEvent() {
		if let mappedBeat = MappedBeat {
			let newEvent = Doc.Story.makeEvent()
			mappedBeat.add(event: newEvent)
		}
	}
	
	@objc private func onContextSurface() {
		if let parent = MappedGroup?.Parent {
			setupFor(group: parent)
		} else if let parent = MappedBeat?.Parent {
			setupFor(group: parent)
		}
	}
	
	private func centerPoint() -> CGPoint {
		return NSMakePoint(visibleRect.midX, visibleRect.midY)
	}
	
	private func canvasGroupFor(nvGroup: NVGroup) -> CanvasGroup? {
		return (_allObjects.filter{$0 is CanvasGroup} as! [CanvasGroup]).first(where: {$0.Group == nvGroup})
	}
	private func canvasBeatFor(nvBeat: NVBeat) -> CanvasBeat? {
		return (_allObjects.filter{$0 is CanvasBeat} as! [CanvasBeat]).first(where: {$0.Beat == nvBeat})
	}
	private func canvasEventFor(nvEvent: NVEvent) -> CanvasEvent? {
		return (_allObjects.filter{$0 is CanvasEvent} as! [CanvasEvent]).first(where: {$0.Event == nvEvent})
	}
	
	// creating canvas elements from novella elements w/o requesting them from the story
	@discardableResult private func makeGroup(nvGroup: NVGroup, at: CGPoint) -> CanvasGroup {
		let obj = CanvasGroup(canvas: self, group: nvGroup)
		_allObjects.append(obj)
		addSubview(obj, positioned: .below, relativeTo: _marquee)
		
		var pos = at
		pos.x -= obj.frame.width * 0.5
		pos.y -= obj.frame.height * 0.5
		obj.frame.origin = pos
		
		return obj
	}
	@discardableResult private func makeBeat(nvBeat: NVBeat, at: CGPoint) -> CanvasBeat {
		let obj = CanvasBeat(canvas: self, beat: nvBeat)
		_allObjects.append(obj)
		addSubview(obj, positioned: .below, relativeTo: _marquee)
		
		var pos = at
		pos.x -= obj.frame.width * 0.5
		pos.y -= obj.frame.height * 0.5
		obj.frame.origin = pos
		
		return obj
	}
	@discardableResult private func makeEvent(nvEvent: NVEvent, at: CGPoint) -> CanvasEvent {
		let obj = CanvasEvent(canvas: self, event: nvEvent)
		_allObjects.append(obj)
		addSubview(obj, positioned: .below, relativeTo: _marquee)
		
		var pos = at
		pos.x -= obj.frame.width * 0.5
		pos.y -= obj.frame.height * 0.5
		obj.frame.origin = pos
		
		return obj
	}
	
	func moveSelection(delta: CGPoint) {
		Selection.Selection.forEach { (obj) in
			var newPos = NSMakePoint(obj.frame.origin.x + delta.x, obj.frame.origin.y + delta.y)
			if newPos.x < 0.0 {
				newPos.x = 0.0
			}
			if (newPos.x + obj.frame.width) > bounds.width {
				newPos.x = bounds.width - obj.frame.width
			}
			if newPos.y < 0.0 {
				newPos.y = 0.0
			}
			if (newPos.y + obj.frame.height) > bounds.height {
				newPos.y = bounds.height - obj.frame.height
			}
			obj.move(to: newPos)
		}
	}
}

extension Canvas: NVStoryDelegate {
	func nvStoryDidMakeGroup(story: NVStory, group: NVGroup) {
	}
	
	func nvStoryDidMakeBeat(story: NVStory, beat: NVBeat) {
	}
	
	func nvStoryDidMakeEvent(story: NVStory, event: NVEvent) {
	}
	
	func nvStoryDidMakeEntity(story: NVStory, entity: NVEntity) {
	}
	
	func nvStoryDidMakeBeatLink(story: NVStory, link: NVBeatLink) {
	}
	
	func nvStoryDidMakeEventLink(story: NVStory, link: NVEventLink) {
	}
	
	func nvStoryDidMakeVariable(story: NVStory, variable: NVVariable) {
	}
	
	func nvStoryDidDeleteGroup(story: NVStory, group: NVGroup) {
	}
	
	func nvStoryDidDeleteBeat(story: NVStory, beat: NVBeat) {
	}
	
	func nvStoryDidDeleteEvent(story: NVStory, event: NVEvent) {
	}
	
	func nvStoryDidDeleteEntity(story: NVStory, entity: NVEntity) {
	}
	
	func nvStoryDidDeleteBeatLink(story: NVStory, link: NVBeatLink) {
	}
	
	func nvStoryDidDeleteEventLink(story: NVStory, link: NVEventLink) {
	}
	
	func nvStoryDidDeleteVariable(story: NVStory, variable: NVVariable) {
	}
	
	func nvGroupLabelDidChange(story: NVStory, group: NVGroup) {
	}
	
	func nvGroupEntryDidChange(story: NVStory, group: NVGroup) {
	}
	
	func nvGroupDidAddBeat(story: NVStory, group: NVGroup, beat: NVBeat) {
		if group != MappedGroup {
			return
		}
		makeBeat(nvBeat: beat, at: Doc.Positions[beat.UUID] ?? centerPoint())
	}
	
	func nvGroupDidRemoveBeat(story: NVStory, group: NVGroup, beat: NVBeat) {
	}
	
	func nvGroupDidAddGroup(story: NVStory, group: NVGroup, child: NVGroup) {
		if group != MappedGroup {
			return
		}

		makeGroup(nvGroup: child, at: Doc.Positions[child.UUID] ?? centerPoint())
	}
	
	func nvGroupDidRemoveGroup(story: NVStory, group: NVGroup, child: NVGroup) {
	}
	
	func nvGroupDidAddBeatLink(story: NVStory, group: NVGroup, link: NVBeatLink) {
	}
	
	func nvGroupDidRemoveBeatLink(story: NVStory, group: NVGroup, link: NVBeatLink) {
	}
	
	func nvBeatLabelDidChange(story: NVStory, beat: NVBeat) {
	}
	
	func nvBeatParallelDidChange(story: NVStory, beat: NVBeat) {
	}
	
	func nvBeatEntryDidChange(story: NVStory, beat: NVBeat) {
	}
	
	func nvBeatDidAddEvent(story: NVStory, beat: NVBeat, event: NVEvent) {
	}
	
	func nvBeatDidRemoveEvent(story: NVStory, beat: NVBeat, event: NVEvent) {
	}
	
	func nvBeatDidAddEventLink(story: NVStory, beat: NVBeat, link: NVEventLink) {
	}
	
	func nvBeatDidRemoveEventLink(story: NVStory, beat: NVBeat, link: NVEventLink) {
	}
	
	func nvDNBeatTangibilityDidChange(story: NVStory, beat: NVDiscoverableBeat) {
	}
	
	func nvDNBeatFunctionalityDidChange(story: NVStory, beat: NVDiscoverableBeat) {
	}
	
	func nvDNBeatClarityDidChange(story: NVStory, beat: NVDiscoverableBeat) {
	}
	
	func nvDNBeatDeliveryDidChange(story: NVStory, beat: NVDiscoverableBeat) {
	}
	
	func nvEventLabelDidChange(story: NVStory, event: NVEvent) {
	}
	
	func nvEventParallelDidChange(story: NVStory, event: NVEvent) {
	}
	
	func nvEventDidAddParticipant(story: NVStory, event: NVEvent, entity: NVEntity) {
	}
	
	func nvEventDidRemoveParticipant(story: NVStory, event: NVEvent, entity: NVEntity) {
	}
	
	func nvVariableNameDidChange(story: NVStory, variable: NVVariable) {
	}
	
	func nvVariableConstantDidChange(story: NVStory, variable: NVVariable) {
	}
	
	func nvVariableValueDidChange(story: NVStory, variable: NVVariable) {
	}
	
	func nvVariableInitialValueDidChange(story: NVStory, variable: NVVariable) {
	}
	
	func nvBeatLinkDestinationDidChange(story: NVStory, link: NVBeatLink) {
	}
	
	func nvEventLinkDestinationDidChange(story: NVStory, link: NVEventLink) {
	}
	
	func nvEntityLabelDidChange(story: NVStory, entity: NVEntity) {
	}
	
	func nvEntityDescriptionDidChange(story: NVStory, entity: NVEntity) {
	}
	
	func nvFunctionCodeDidChange(story: NVStory, function: NVFunction) {
	}
	
	func nvConditionCodeDidChange(story: NVStory, condition: NVCondition) {
	}
}
