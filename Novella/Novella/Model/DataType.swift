//
//  DataType.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

enum DataType {
	case boolean
	case integer
	
	var defaultValue: Any {
		switch self {
		case .boolean: return false
		case .integer: return 0
		}
	}
	
	func matches(value: Any) -> Bool {
		switch self {
		case .boolean: return value is Bool
		case .integer: return value is Int
		}
	}
	
	var stringValue: String {
		switch self {
		case .boolean: return "boolean"
		case .integer: return "integer"
		}
	}
	
	static func fromString(str: String) -> DataType {
		switch str {
		case "boolean": return .boolean
		case "integer": return .integer
		default:
			fatalError("Forgot to handle DataType string conversion!")
		}
	}
}
