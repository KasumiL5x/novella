//
//  NVLinkable.swift
//  novella
//
//  Created by Daniel Green on 12/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//

import Foundation

// new idea for implementing hubs and returns:
//  - Since links can go to sequences/events AND hubs/returns, I cannot just have a single template like now.
//  - Instead, I neeed to use a protocol like this one below.
//  - However, Returns cannot be an Origin, so there needs to be a function to check if a Linkable can be an origin
//    (and then the code would check this when creating them).
//  - I'd need to change all of the functions in the model and interface to handle this new link situation, as the concept of
//    'sequence links' vs 'event links' would basically be gone.

protocol NVLinkable: NVIdentifiable {
	// Returns cannot be an origin.
	func canBecomeOrigin() -> Bool
}
