//
//  DataType.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

public enum DataType {
	case boolean
	case integer
	
	public var defaultValue: Any {
		switch self {
		case .boolean: return false
		case .integer: return 0
		}
	}
	
	public func matches(value: Any) -> Bool {
		switch self {
		case .boolean: return value is Bool
		case .integer: return value is Int
		}
	}
}
