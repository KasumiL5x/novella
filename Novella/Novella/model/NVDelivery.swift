//
//  NVDelivery.swift
//  novella
//
//  Created by dgreen on 09/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Foundation

class NVDelivery: NVNode {
	// MARK: - Properties
	var Content: String = "" {
		didSet {
			NVLog.log("Delivery (\(ID)) content set to \"\(Content)\".", level: .info)
			_story.Delegates.forEach{$0.nvDeliveryContentDidChange(delivery: self)}
		}
	}
	var Directions: String = "" {
		didSet {
			NVLog.log("Delivery (\(ID)) directions set to \"\(Directions)\".", level: .info)
			_story.Delegates.forEach{$0.nvDeliveryDirectionsDidChange(delivery: self)}
		}
	}
	var Preview: String = "" {
		didSet {
			NVLog.log("Delivery (\(ID)) preview set to \"\(Preview)\".", level: .info)
			_story.Delegates.forEach{$0.nvDeliveryPreviewDidChange(delivery: self)}
		}
	}
}

