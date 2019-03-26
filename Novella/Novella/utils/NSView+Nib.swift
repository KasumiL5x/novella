//
//  NSView+Nib.swift
//  novella
//
//  Created by Daniel Green on 14/12/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

extension NSView {
	class func initFromNib<T: NSView>() -> T? {
		var tlo: NSArray?
		guard Bundle.main.loadNibNamed(String(describing: self), owner: self, topLevelObjects: &tlo) else {
			return nil
		}
		return tlo?.first(where: {$0 is T}) as? T
	}
}
