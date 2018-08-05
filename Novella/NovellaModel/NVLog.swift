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
		
		public static let none    = Level(rawValue: 0)
		public static let info    = Level(rawValue: 1 << 0) // generic printing
		public static let warning = Level(rawValue: 1 << 1) // non-critical failures
		public static let error   = Level(rawValue: 1 << 2) // critical failures
		public static let debug   = Level(rawValue: 1 << 3) // debug information
		public static let all     = Level(rawValue: ~0)
		
		func toString() -> String {
			switch self {
			case Level.warning:
				return "Warning"
			case Level.error:
				return "Error"
			default:
				return ""
			}
		}
	}
	
	public static var logLevel: Level = [Level.all]
	static let dateFormatter = DateFormatter()
	
	public static func log(_ msg: String, level: Level) {
		if !NVLog.logLevel.contains(level) {
			return
		}
		
		NVLog.dateFormatter.timeStyle = .medium
		NVLog.dateFormatter.dateStyle = .short
		let time = NVLog.dateFormatter.string(from: Date())
		
		let extra = level.toString()
		print("(\(time)) Novella" + (extra.isEmpty ? ": " : " " + extra + ": ") + msg)
	}
}
