//
//  NVLog.swift
//  novella
//
//  Created by Daniel Green on 01/12/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

class NVLog {
	struct Level: OptionSet {
		let rawValue: Int
		
		init(rawValue: Int) {
			self.rawValue = rawValue
		}
		
		static let none    = Level(rawValue: 0)
		static let info    = Level(rawValue: 1 << 0) // generic printing
		static let warning = Level(rawValue: 1 << 1) // non-critical failures
		static let error   = Level(rawValue: 1 << 2) // critical failures
		static let debug   = Level(rawValue: 1 << 3) // debug information
		static let all     = Level(rawValue: ~0)
		
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
	
	static var logLevel: Level = [Level.all]
	static let dateFormatter = DateFormatter()
	
	static func log(_ msg: String, level: Level) {
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
