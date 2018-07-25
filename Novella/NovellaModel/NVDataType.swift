//
//  NVDataType.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

public enum NVDataType {
	case boolean
	case integer
	case double
	
	var defaultValue: Any {
		switch self {
		case .boolean: return false
		case .integer: return 0
		case .double: return 0.0
		}
	}
	
	public static var all: [NVDataType] {
		get{
			return [
				.boolean,
				.integer,
				.double
			]
		}
	}
	
	func matches(value: Any) -> Bool {
		switch self {
		case .boolean: return value is Bool
		case .integer: return value is Int
		case .double: return value is Double
		}
	}
	
	public var stringValue: String {
		switch self {
		case .boolean: return "boolean"
		case .integer: return "integer"
		case .double: return "double"
		}
	}
	
	public static func fromString(str: String) -> NVDataType {
		switch str {
		case "boolean": return .boolean
		case "integer": return .integer
		case "double": return .double
		default:
			NVLog.log("Forgot to handle DataType string conversion (\(str))!", level: .error)
			fatalError()
		}
	}
}
