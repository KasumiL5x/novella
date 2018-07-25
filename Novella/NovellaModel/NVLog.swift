//
//  NVLog.swift
//  NovellaModel
//
//  Created by Daniel Green on 18/07/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVLog {
	public struct Level: OptionSet {
		public let rawValue: Int
		
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
		
		static let none    = Level(rawValue: 0)
		static let info    = Level(rawValue: 1 << 0) // generic printing
		static let warning = Level(rawValue: 1 << 1) // non-critical failures
		static let error   = Level(rawValue: 1 << 2) // critical failures
		static let debug   = Level(rawValue: 1 << 3) // debug information
		static let all     = Level(rawValue: ~0)
	}
	
	public static var logLevel: Level = [Level.all]
	
	public static func log(_ msg: String, level: Level) {
		if !NVLog.logLevel.contains(level) {
			return
		}
		print("Novella: " + msg)
	}
}
