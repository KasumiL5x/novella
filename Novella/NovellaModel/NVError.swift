//
//  NVError.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

public enum NVError: Error {
	// new errors
	case invalid(String)
	case nameTaken(String)
	
	// old errors
	case nameAlreadyTaken(String)
	case notImplemented(String)
	case dataTypeMismatch(String)
	case isConstant(String)
}
