//
//  Curve.swift
//  novella
//
//  Created by Daniel Green on 03/04/2019.
//  Copyright © 2019 dgreen. All rights reserved.
//
//  Based on this project: https://github.com/chen0040/cpp-spline
//

import Foundation

enum CurveType {
	case bspline
	case bezier
	case catmullrom
	case curve
}

class Curve {
	private var _waypoints: [CGPoint] = []
	private var _nodes: [CGPoint] = []
	private var _distances: [CGFloat] = []
	private var _steps: Int = 10
	private var _curveType: CurveType = .catmullrom
	
	public var Nodes: [CGPoint] {
		get{ return _nodes }
	}
	
	init(steps: Int, type: CurveType) {
		_steps = steps
		_curveType = type
	}
	
	func clear() {
		_nodes = []
		_waypoints = []
		_distances = []
	}
	
	func add(point: CGPoint) {
		_waypoints.append(point)
		onWaypointAdded()
	}
	
	private func add(node: CGPoint) {
		_nodes.append(node)
		
		if _nodes.count == 1 {
			_distances.append(0)
		} else {
			let newNodeIndex = _nodes.count - 1
			let segmentDistance = (_nodes[newNodeIndex] - _nodes[newNodeIndex - 1]).length()
			_distances.append(segmentDistance + _distances[newNodeIndex - 1])
		}
	}
	
	private func onWaypointAdded() {
		switch _curveType {
		case .bspline:
			if _waypoints.count < 4 {
				return
			}
			
			let newControlPointIndex = _waypoints.count - 1
			let pt = newControlPointIndex - 3
			for i in 0..._steps {
				let u = CGFloat(i) / CGFloat(_steps)
				add(node: bsplineInterpolate(u: u, p0: _waypoints[pt], p1: _waypoints[pt+1], p2: _waypoints[pt+2], p3: _waypoints[pt+3]))
			}
			
		case .bezier:
			if _waypoints.count < 4 {
				return
			}
			
			let newControlPointIndex = _waypoints.count - 1
			if newControlPointIndex == 3 {
				for i in 0..._steps {
					let u = CGFloat(i) / CGFloat(_steps)
					add(node: bezierInterpolate(u: u, p0: _waypoints[0], p1: _waypoints[1], p2: _waypoints[2], p3: _waypoints[3]))
				}
			} else {
				if newControlPointIndex % 2 == 0 {
					return
				}
				let pt = newControlPointIndex - 2
				for i in 0..._steps {
					let u = CGFloat(i) / CGFloat(_steps)
					let point4 = 2.0 * _waypoints[pt] - _waypoints[pt-1]
					add(node: bezierInterpolate(u: u, p0: _waypoints[pt], p1: point4, p2: _waypoints[pt+1], p3: _waypoints[pt+2]))
				}
			}
			
		case .catmullrom:
			if _waypoints.count < 4 {
				return
			}
			
			let newControlPointIndex = _waypoints.count - 1
			let pt = newControlPointIndex - 2
			for i in 0..._steps {
				let u = CGFloat(i) / CGFloat(_steps)
				add(node: catmullRomInterpolate(u: u, p0: _waypoints[pt-1], p1: _waypoints[pt], p2: _waypoints[pt+1], p3: _waypoints[pt+2]))
			}
			
		case .curve:
			break
		}
	}
	
	private func bsplineInterpolate(u: CGFloat, p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGPoint {
		var point = CGPoint()
		point = u*u*u*((-1.0) * p0 + 3.0 * p1 - 3.0 * p2 + p3) / 6.0
		point += u*u*(3.0*p0 - 6.0 * p1 + 3.0 * p2) / 6.0
		point += u*((-3.0) * p0 + 3.0 * p2) / 6.0
		point += (p0+4.0*p1+p2) / 6.0
		return point
	}
	
	private func catmullRomInterpolate(u: CGFloat, p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGPoint {
		var point = CGPoint()
		point = u*u*u*((-1.0) * p0 + 3.0 * p1 - 3.0 * p2 + p3) / 2.0
		point += u*u*(2.0*p0 - 5.0 * p1 + 4.0 * p2 - p3) / 2.0
		point += u*((-1.0) * p0 + p2) / 2.0
		point += p1
		return point
	}
	
	private func bezierInterpolate(u: CGFloat, p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGPoint {
		var point = CGPoint()
		point = u*u*u*((-1.0) * p0 + 3.0 * p1 - 3.0 * p2 + p3)
		point += u*u*(3.0*p0 - 6.0 * p1 + 3.0 * p2)
		point += u*((-3.0) * p0 + 3.0 * p1)
		point += p0
		return point
	}
}
