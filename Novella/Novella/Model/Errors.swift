//
//  ErrorExtension.swift
//  novella
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

enum Errors: Error {
	// new errors
	case invalid(String)
	case nameTaken(String)
	
	// old errors
	case nameNotFound(String)
	case nameAlreadyTaken(String)
	case notImplemented(String)
	case dataTypeMismatch(String)
	case isConstant(String)
}
