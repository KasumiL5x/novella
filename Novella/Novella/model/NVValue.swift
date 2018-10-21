//
//  NVValue.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVValue: Hashable {
	var Raw: NVRawValue
	
	init(_ value: NVRawValue) {
		self.Raw = value
	}
	
	// MARK: Hashable
	var hashValue: Int {
		return ObjectIdentifier(self).hashValue
	}
	// MARK: Equatable
	static func ==(lhs: NVValue, rhs: NVValue) -> Bool {
		return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
	}
}

enum NVValueType {
	case boolean
	case integer
	case double
	
	var toString: String {
		switch self {
		case .boolean:
			return "boolean"
		case .integer:
			return "integer"
		case .double:
			return "double"
		}
	}
	
	static var all: [NVValueType] {
		return [.boolean, .integer, .double]
	}
}

enum NVRawValue {
	case boolean(Bool)
	case integer(Int32)
	case double(Double)
	
	var type: NVValueType {
		switch self {
		case NVRawValue.boolean:
			return NVValueType.boolean
		case NVRawValue.integer:
			return NVValueType.integer
		case NVRawValue.double:
			return NVValueType.double
		}
	}
	
	var asBool: Bool {
		switch self {
		case .boolean(let boolVal):
			return boolVal
		case .integer(let intVal):
			return intVal != 0
		case .double(let doubleVal):
			return NSNumber(value: doubleVal).boolValue
		}
	}
	
	var asInt: Int32 {
		switch self {
		case .boolean(let boolVal):
			return boolVal ? 1 : 0
		case .integer(let intVal):
			return intVal
		case .double(let doubleVal):
			return Int32(doubleVal)
		}
	}
	
	var asDouble: Double {
		switch self {
		case .boolean(let boolVal):
			return boolVal ? 1.0 : 0.0
		case .integer(let intVal):
			return Double(intVal)
		case .double(let doubleVal):
			return doubleVal
		}
	}
	
	func isEqualTo(_ rhs: NVRawValue) -> Bool {
		if self.type != rhs.type {
			return false
		}
		
		switch self.type {
		case .boolean:
			return self.asBool == rhs.asBool
		case .integer:
			return self.asInt == rhs.asInt
		case .double:
			return fabs(self.asDouble - rhs.asDouble) <= 0.001
		}
	}
}
