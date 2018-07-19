//
//  NVLog.swift
//  NovellaModel
//
//  Created by Daniel Green on 18/07/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public class NVLog {
	public enum Verbosity: Int {
		case none // nothing at all
		case simple // only information
		case verbose // warnings and information
	}
	
	public static var level: Verbosity = .verbose
	
	public static func log(_ msg: String, level: Verbosity = .simple) {
		if level == .none || level.rawValue > NVLog.level.rawValue {
			return
		}
		print("Novella: " + msg)
	}
}

// tests below from repl.it session
//// default verbosity
//print("Default verbosity:")
//NVLog.log("Default verbosity. Should print.")
//NVLog.log("None. Should not print.", level: .none)
//NVLog.log("Simple. Should print.", level: .simple)
//NVLog.log("Verbose. Should print.", level: .verbose)
//
//// no verbosity
//print("\nNo verbosity:")
//NVLog.level = .none
//NVLog.log("Default verbosity. Should not print.")
//NVLog.log("None. Should not print.", level: .none)
//NVLog.log("Simple. Should not print.", level: .simple)
//NVLog.log("Verbose. Should not print.", level: .verbose)
//
//// simple verbosity
//print("\nSimple verbosity:")
//NVLog.level = .simple
//NVLog.log("Default verbosity. Should print.")
//NVLog.log("None. Should not print.", level: .none)
//NVLog.log("Simple. Should print.", level: .simple)
//NVLog.log("Verbose. Should not print.", level: .verbose)
//
//// no verbosity
//print("\nVerbose verbosity:")
//NVLog.level = .verbose
//NVLog.log("Default verbosity. Should  print.")
//NVLog.log("None. Should not print.", level: .none)
//NVLog.log("Simple. Should print.", level: .simple)
//NVLog.log("Verbose. Should print.", level: .verbose)
