//
//  GraphViewDelegate.swift
//  Novella
//
//  Created by Daniel Green on 17/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import NovellaModel

protocol GraphViewDelegate {
	func onSelectionChanged(graphView: GraphView, selection: [Node])
}

extension GraphViewDelegate {
	func onSelectionChanged(graphView: GraphView, selection: [Node]) {
	}
}
