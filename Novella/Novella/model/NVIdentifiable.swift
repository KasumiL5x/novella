//
//  NVIdentifiable.swift
//  novella
//
//  Created by Daniel Green on 30/11/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import Foundation

protocol NVIdentifiable {
	var UUID: NSUUID {get set}
}
