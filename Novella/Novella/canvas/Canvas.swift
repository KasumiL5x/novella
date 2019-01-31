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
	
	private(set) var Doc: Document
	private(set) var MappedGroup: NVGroup?
	private(set) var MappedSequence: NVSequence?
	private let _background: CanvasBackground
	private let _marquee: CanvasMarquee
	private var _allObjects: [CanvasObject]
	private var _allBenches: [CanvasObject:CanvasBench]
	private(set) var Selection: CanvasSelection
	private var _contextMenu: NSMenu
	private var _lastContextPos: CGPoint
	private let _addGroupMenuItem: NSMenuItem
	private let _addSequenceMenuItem: NSMenuItem
	private let _addEventMenuItem: NSMenuItem
	private let _surfaceMenuItem: NSMenuItem
	//
	private var _rmbPanInitialLocation: CGPoint
	private var _rmbPanCurrentLocation: CGPoint
	private var _rmbPanInitialMag: CGFloat
	
	init(doc: Document) {
		self.Doc = doc
		self.MappedGroup = nil
		self.MappedSequence = nil
		let initialFrame = NSMakeRect(0, 0, Canvas.DEFAULT_SIZE, Canvas.DEFAULT_SIZE)
		self._background = CanvasBackground(frame: initialFrame)
		self._marquee = CanvasMarquee(frame: initialFrame)
		self._allObjects = []
		self._allBenches = [:]
		self.Selection = CanvasSelection()
		self._contextMenu = NSMenu()
		self._lastContextPos = CGPoint.zero
		self._addGroupMenuItem = NSMenuItem(title: "Group", action: #selector(Canvas.onContextAddGroup), keyEquivalent: "")
		self._addSequenceMenuItem = NSMenuItem(title: "Sequence", action: #selector(Canvas.onContextAddSequence), keyEquivalent: "")
		self._addEventMenuItem = NSMenuItem(title: "Event", action: #selector(Canvas.onContextAddEvent), keyEquivalent: "")
		self._surfaceMenuItem = NSMenuItem(title: "Surface", action: #selector(Canvas.onContextSurface), keyEquivalent: "")
		//
		self._rmbPanInitialLocation = CGPoint.zero
		self._rmbPanCurrentLocation = CGPoint.zero
		self._rmbPanInitialMag = 0.0
		super.init(frame: initialFrame)
		
		Selection.TheCanvas = self
		
		wantsLayer = true
		
		let pan = NSPanGestureRecognizer(target: self, action: #selector(Canvas.onPan))
		pan.buttonMask = 0x1
		addGestureRecognizer(pan)
		
		let rmbPan = NSPanGestureRecognizer(target: self, action: #selector(Canvas.onRmbPan))
		rmbPan.buttonMask = 0x2
		addGestureRecognizer(rmbPan)
		
		let ctx = NSClickGestureRecognizer(target: self, action: #selector(Canvas.onContext))
		ctx.buttonMask = 0x2
		addGestureRecognizer(ctx)
		
		let addMenu = NSMenu()
		addMenu.autoenablesItems = false
		addMenu.addItem(_addGroupMenuItem)
		addMenu.addItem(_addSequenceMenuItem)
		addMenu.addItem(_addEventMenuItem)
		let addMenuItem = NSMenuItem()
		addMenuItem.title = "Add..."
		addMenuItem.submenu = addMenu
		_contextMenu.addItem(addMenuItem)
		_contextMenu.addItem(NSMenuItem.separator())
		_contextMenu.addItem(_surfaceMenuItem)
		_contextMenu.autoenablesItems = false
		
		doc.Story.addDelegate(self)
	}
	required init?(coder decoder: NSCoder) {
		fatalError()
	}
	
	func setupFor(group: NVGroup) {
		MappedGroup = group
		MappedSequence = nil
		
		_addGroupMenuItem.isEnabled = true
		_addSequenceMenuItem.isEnabled = true
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
		// add all child sequences
		for child in group.Sequences {
			makeSequence(nvSequence: child, at: Doc.Positions[child.UUID] ?? centerPoint())
		}
		// add all sequence links
		for child in group.SequenceLinks {
			addSequenceLink(link: child)
		}
		
		// post setup for group notification
		NotificationCenter.default.post(name: NSNotification.Name.nvCanvasSetupForGroup, object: nil, userInfo: [
			"group": group
		])
	}
	
	func setupFor(sequence: NVSequence) {
		MappedSequence = sequence
		MappedGroup = nil
		
		_addGroupMenuItem.isEnabled = false
		_addSequenceMenuItem.isEnabled = false
		_addEventMenuItem.isEnabled = true
		_surfaceMenuItem.isEnabled = sequence.Parent != nil
		
		_allObjects = []
		_allBenches = [:]
		
		Selection.clear()
		
		subviews.removeAll()
		addSubview(_background)
		addSubview(_marquee)
		
		// add all child events
		for child in sequence.Events {
			makeEvent(nvEvent: child, at: Doc.Positions[child.UUID] ?? centerPoint())
		}
		// add all event links
		for child in sequence.EventLinks {
			addEventLink(link: child)
		}
		
		// post setup for sequence notification
		NotificationCenter.default.post(name: NSNotification.Name.nvCanvasSetupForSequence, object: nil, userInfo: [
			"sequence": sequence
		])
	}
	
	override func mouseDown(with event: NSEvent) {  // this is the default mousedown w/o any gestures
		Selection.clear()
	}
	
	func objectAt(point: CGPoint, ignoring: CanvasObject?=nil) -> CanvasObject? {
		for curr in _allObjects {
			let hit = curr.hitTest(point)
			// ignore objects that didn't hittest themselves
			if hit != curr {
				continue
			}
			// also ignore a result that is the same as the 'ignoring' value if it's not nil (e.g., self)
			if ignoring != nil && ignoring == hit {
				continue
			}
			return curr
		}
		return nil
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
	
	@objc private func onRmbPan(gesture: NSPanGestureRecognizer) {
		guard let scrollView = superview?.superview as? NSScrollView else {
			print("Attempted to RMB pan Canvas but it was not correctly embedded within an NSScrollView (NSScrollView->NSClipView->Canvas).")
			return
		}
		
		switch gesture.state {
		case .began:
			_rmbPanInitialLocation = gesture.location(in: scrollView)
			_rmbPanCurrentLocation = _rmbPanInitialLocation
			_rmbPanInitialMag = scrollView.magnification
			
		case .changed:
			let currPos = gesture.location(in: scrollView)
			
			if NSApp.currentEvent?.modifierFlags.contains(.shift) ?? false {
				let diff = (currPos - _rmbPanInitialLocation)
				let dist = (diff.x - diff.y) * 0.001 // TODO: variable this?
				scrollView.magnification = _rmbPanInitialMag + dist
			} else {
				let panSpeed: CGFloat = 0.5 // TODO: variable this
				var diff = (currPos - _rmbPanCurrentLocation) * panSpeed
				diff.x *= scrollView.isFlipped ? -1.0 : 1.0
				diff.y *= scrollView.isFlipped ? 1.0 : -1.0
				let center = visibleRect.origin + diff
				scrollView.contentView.scroll(to: center)
				scrollView.reflectScrolledClipView(scrollView.contentView)
			}
			
			_rmbPanCurrentLocation = currPos
			
		case .cancelled, .ended:
			break
			
		default:
			break
		}
	}
	
	@objc private func onContext(gesture: NSClickGestureRecognizer) {
		// must be set up to show context menu
		if MappedGroup != nil || MappedSequence != nil {
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
	
	@objc private func onContextAddSequence() {
		if let mappedGroup = MappedGroup {
			let newSequence = Doc.Story.makeSequence()
			mappedGroup.add(sequence: newSequence)
			canvasSequenceFor(nvSequence: newSequence)?.move(to: _lastContextPos)
		}
	}
	
	@objc private func onContextAddEvent() {
		if let mappedSequence = MappedSequence {
			let newEvent = Doc.Story.makeEvent()
			mappedSequence.add(event: newEvent)
			canvasEventFor(nvEvent: newEvent)?.move(to: _lastContextPos)
		}
	}
	
	@objc private func onContextSurface() {
		if let parent = MappedGroup?.Parent {
			setupFor(group: parent)
		} else if let parent = MappedSequence?.Parent {
			setupFor(group: parent)
		}
	}
	
	private func centerPoint() -> CGPoint {
		return NSMakePoint(visibleRect.midX, visibleRect.midY)
	}
	
	private func canvasGroupFor(nvGroup: NVGroup) -> CanvasGroup? {
		return (_allObjects.filter{$0 is CanvasGroup} as! [CanvasGroup]).first(where: {$0.Group == nvGroup})
	}
	func canvasSequenceFor(nvSequence: NVSequence) -> CanvasSequence? {
		return (_allObjects.filter{$0 is CanvasSequence} as! [CanvasSequence]).first(where: {$0.Sequence == nvSequence})
	}
	func canvasEventFor(nvEvent: NVEvent) -> CanvasEvent? {
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
	@discardableResult private func makeSequence(nvSequence: NVSequence, at: CGPoint) -> CanvasSequence {
		let obj = CanvasSequence(canvas: self, sequence: nvSequence)
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
	
	func makeSequenceLink(sequence: CanvasSequence) {
		// sequences only exist within groups so ensure a group is mapped
		if let group = MappedGroup {
			let link = Doc.Story.makeSequenceLink(origin: sequence.Sequence, dest: nil)
			group.add(sequenceLink: link)
		}
	}
	private func addEventLink(link: NVEventLink) {
		guard let obj = canvasEventFor(nvEvent: link.Origin) else {
			NVLog.log("Tried to add an EventLink but couldn't find a CanvasEvent for the origin!", level: .error)
			return
		}
		benchFor(obj: obj)?.add(CanvasEventLink(canvas: self, origin: obj, link: link))
	}
	func makeEventLink(event: CanvasEvent) {
		// events only exist within sequences so ensure a sequence is mapped
		if let sequence = MappedSequence {
			let link = Doc.Story.makeEventLink(origin: event.Event, dest: nil)
			sequence.add(eventLink: link)
		}
	}
	private func addSequenceLink(link: NVSequenceLink) {
		guard let obj = canvasSequenceFor(nvSequence: link.Origin) else {
			NVLog.log("Tried to add a SequenceLink but couldn't find a CanvasSequence for the origin!", level: .error)
			return
		}
		benchFor(obj: obj)?.add(CanvasSequenceLink(canvas: self, origin: obj, link: link))
	}
}

extension Canvas: NVStoryDelegate {
	func nvStoryDidMakeGroup(story: NVStory, group: NVGroup) {
	}
	
	func nvStoryDidMakeSequence(story: NVStory, sequence: NVSequence) {
	}
	
	func nvStoryDidMakeEvent(story: NVStory, event: NVEvent) {
	}
	
	func nvStoryDidMakeEntity(story: NVStory, entity: NVEntity) {
	}
	
	func nvStoryDidMakeSequenceLink(story: NVStory, link: NVSequenceLink) {
		addSequenceLink(link: link)
	}
	
	func nvStoryDidMakeEventLink(story: NVStory, link: NVEventLink) {
		addEventLink(link: link)
	}
	
	func nvStoryDidMakeVariable(story: NVStory, variable: NVVariable) {
	}
	
	func nvStoryDidMakeFunction(story: NVStory, function: NVFunction) {
	}
	
	func nvStoryDidMakeCondition(story: NVStory, condition: NVCondition) {
	}
	
	func nvStoryDidDeleteGroup(story: NVStory, group: NVGroup) {
	}
	
	func nvStoryDidDeleteSequence(story: NVStory, sequence: NVSequence) {
	}
	
	func nvStoryDidDeleteEvent(story: NVStory, event: NVEvent) {
	}
	
	func nvStoryDidDeleteEntity(story: NVStory, entity: NVEntity) {
	}
	
	func nvStoryDidDeleteSequenceLink(story: NVStory, link: NVSequenceLink) {
	}
	
	func nvStoryDidDeleteEventLink(story: NVStory, link: NVEventLink) {
	}
	
	func nvStoryDidDeleteVariable(story: NVStory, variable: NVVariable) {
	}
	
	func nvStoryDidDeleteFunction(story: NVStory, function: NVFunction) {
	}
	
	func nvStoryDidDeleteCondition(story: NVStory, condition: NVCondition) {
	}
	
	func nvGroupLabelDidChange(story: NVStory, group: NVGroup) {
		canvasGroupFor(nvGroup: group)?.reloadData()
	}
	
	func nvGroupEntryDidChange(story: NVStory, group: NVGroup, oldEntry: NVSequence?, newEntry: NVSequence?) {
		if let old = oldEntry {
			canvasSequenceFor(nvSequence: old)?.reloadData()
		}
		if let new = newEntry {
			canvasSequenceFor(nvSequence: new)?.reloadData()
		}
	}
	
	func nvGroupDidAddSequence(story: NVStory, group: NVGroup, sequence: NVSequence) {
		if group != MappedGroup {
			return
		}
		makeSequence(nvSequence: sequence, at: Doc.Positions[sequence.UUID] ?? centerPoint())
	}
	
	func nvGroupDidRemoveSequence(story: NVStory, group: NVGroup, sequence: NVSequence) {
	}
	
	func nvGroupDidAddGroup(story: NVStory, group: NVGroup, child: NVGroup) {
		if group != MappedGroup {
			return
		}

		makeGroup(nvGroup: child, at: Doc.Positions[child.UUID] ?? centerPoint())
	}
	
	func nvGroupDidRemoveGroup(story: NVStory, group: NVGroup, child: NVGroup) {
	}
	
	func nvGroupDidAddSequenceLink(story: NVStory, group: NVGroup, link: NVSequenceLink) {
	}
	
	func nvGroupDidRemoveSequenceLink(story: NVStory, group: NVGroup, link: NVSequenceLink) {
	}
	
	func nvSequenceLabelDidChange(story: NVStory, sequence: NVSequence) {
		canvasSequenceFor(nvSequence: sequence)?.reloadData()
	}
	
	func nvSequenceParallelDidChange(story: NVStory, sequence: NVSequence) {
		canvasSequenceFor(nvSequence: sequence)?.reloadData()
	}
	
	func nvSequenceEntryDidChange(story: NVStory, sequence: NVSequence, oldEntry: NVEvent?, newEntry: NVEvent?) {
		if let old = oldEntry {
			canvasEventFor(nvEvent: old)?.reloadData()
		}
		if let new = newEntry {
			canvasEventFor(nvEvent: new)?.reloadData()
		}
	}
	
	func nvSequenceDidAddEvent(story: NVStory, sequence: NVSequence, event: NVEvent) {
		if sequence != MappedSequence {
			return
		}
		makeEvent(nvEvent: event, at: Doc.Positions[event.UUID] ?? centerPoint())
	}
	
	func nvSequenceDidRemoveEvent(story: NVStory, sequence: NVSequence, event: NVEvent) {
	}
	
	func nvSequenceDidAddEventLink(story: NVStory, sequence: NVSequence, link: NVEventLink) {
	}
	
	func nvSequenceDidRemoveEventLink(story: NVStory, sequence: NVSequence, link: NVEventLink) {
	}
	
	func nvDNSequenceTangibilityDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
	}
	
	func nvDNSequenceFunctionalityDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
	}
	
	func nvDNSequenceClarityDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
	}
	
	func nvDNSequenceDeliveryDidChange(story: NVStory, sequence: NVDiscoverableSequence) {
	}
	
	func nvEventLabelDidChange(story: NVStory, event: NVEvent) {
		canvasEventFor(nvEvent: event)?.reloadData()
	}
	
	func nvEventParallelDidChange(story: NVStory, event: NVEvent) {
		canvasEventFor(nvEvent: event)?.reloadData()
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
	
	func nvSequenceLinkDestinationDidChange(story: NVStory, link: NVSequenceLink) {
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
