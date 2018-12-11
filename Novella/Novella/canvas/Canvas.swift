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
	private var _allBenches: [CanvasObject:CanvasBench]
	private(set) var Selection: CanvasSelection
	private var _contextMenu: NSMenu
	private var _lastContextPos: CGPoint
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
		self._allBenches = [:]
		self.Selection = CanvasSelection()
		self._contextMenu = NSMenu()
		self._lastContextPos = CGPoint.zero
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
		
		_allObjects = []
		_allBenches = [:]
		
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
		
		_allObjects = []
		_allBenches = [:]
		
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
	
	private func makeBench() -> CanvasBench {
		let bench = CanvasBench()
		addSubview(bench, positioned: .above, relativeTo: _marquee)
		bench.translatesAutoresizingMaskIntoConstraints = false
		return bench
	}
	private func benchFor(obj: CanvasObject) -> CanvasBench? {
		return _allBenches.keys.contains(obj) ? _allBenches[obj] : nil
	}
	
	@objc private func onPan(gesture: NSPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			_marquee.Origin = gesture.location(in: self)
			_marquee.InMarquee = true
			
		case .changed:
			if _marquee.InMarquee {
				_marquee.End = gesture.location(in: self)
				
				// handle un/priming of non-selected objects in the selection marquee
				let objsInMarquee = allObjectsIn(rect: _marquee.Region)
				_allObjects.filter{$0.CurrentState != .selected}.forEach { (obj) in
					obj.CurrentState = objsInMarquee.contains(obj) ? .primed : .normal
				}
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
		// must be set up to show context menu
		if MappedGroup != nil || MappedBeat != nil {
			_lastContextPos = gesture.location(in: self)
			NSMenu.popUpContextMenu(_contextMenu, with: NSApp.currentEvent!, for: self)
		}
	}
	
	@objc private func onContextAddGroup() {
		if let mappedGroup = MappedGroup {
			let newGroup = Doc.Story.makeGroup()
			mappedGroup.add(group: newGroup)
			canvasGroupFor(nvGroup: newGroup)?.move(to: _lastContextPos)
		}
	}
	
	@objc private func onContextAddBeat() {
		if let mappedGroup = MappedGroup {
			let newBeat = Doc.Story.makeBeat()
			mappedGroup.add(beat: newBeat)
			canvasBeatFor(nvBeat: newBeat)?.move(to: _lastContextPos)
		}
	}
	
	@objc private func onContextAddEvent() {
		if let mappedBeat = MappedBeat {
			let newEvent = Doc.Story.makeEvent()
			mappedBeat.add(event: newEvent)
			canvasEventFor(nvEvent: newEvent)?.move(to: _lastContextPos)
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

		let bench = makeBench()
		_allBenches[obj] = bench
		bench.constrain(to: obj)
		
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
		
		let bench = makeBench()
		_allBenches[obj] = bench
		bench.constrain(to: obj)
		
		return obj
	}
	
	// shared object functionality
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
	
	func makeBeatLink(beat: CanvasBeat) {
		// beats only exist within groups so ensure a group is mapped
		if let group = MappedGroup {
			let link = Doc.Story.makeBeatLink(origin: beat.Beat, dest: nil)
			group.add(beatLink: link)
		}
	}
	func makeEventLink(event: CanvasEvent) {
		// events only exist within beats so ensure a beat is mapped
		if let beat = MappedBeat {
			let link = Doc.Story.makeEventLink(origin: event.Event, dest: nil)
			beat.add(eventLink: link)
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
		guard let obj = canvasBeatFor(nvBeat: link.Origin) else {
			NVLog.log("Tried to add a BeatLink but couldn't find a CanvasBeat for the origin!", level: .error)
			return
		}
		benchFor(obj: obj)?.add(CanvasBeatLink(link: link))
	}
	
	func nvStoryDidMakeEventLink(story: NVStory, link: NVEventLink) {
		guard let obj = canvasEventFor(nvEvent: link.Origin) else {
			NVLog.log("Tried to add an EventLink but couldn't find a CanvasEvent for the origin!", level: .error)
			return
		}
		benchFor(obj: obj)?.add(CanvasEventLink(link: link))
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
