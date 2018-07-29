//
//  NVEntity.swift
//  NovellaModel
//
//  Created by Daniel Green on 25/06/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVEntity: NVObject {
	// MARK: - Variables -
	private var _imageName: String
	private var _cachedImage: NSImage?
	
	// MARK: - Properties -
	public var ImageName: String {
		get{ return _imageName }
		set{
			_imageName = newValue
			cacheImage()
			
			NVLog.log("Entity (\(self.UUID)) image changed to (\(self.ImageName)).", level: .info)
			_manager.Delegates.forEach{$0.onStoryEntityImageChanged(entity: self)}
		}
	}
	public var CachedImage: NSImage? {
		get{ return _cachedImage }
	}
	
	// MARK: - Initialization -
	override init(manager: NVStoryManager, uuid: NSUUID) {
		_imageName = ""
		_cachedImage = nil
		super.init(manager: manager, uuid: uuid)
	}
	
	// MARK: - Functions -
	public override func isLinkable() -> Bool {
		return false
	}
	
	private func cacheImage() {
		_cachedImage = NSImage(byReferencingFile: _imageName)
	}
}
