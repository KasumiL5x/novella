//
//  VariableSetTests.swift
//  novellaTests
//
//  Created by Daniel Green on 10/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import XCTest
@testable import Novella

class FolderTests: XCTestCase {
	var root = Folder(name: "root")
	
	override func setUp() {
		super.setUp()
		
		root = Folder(name: "root")
	}
	
	// MARK: Folders
	func testSetName() {
		let f = Novella.Folder(name: "folder")
		
		// change name without a parent fodler
		XCTAssertNoThrow(try f.setName(name: "daniel"))
		XCTAssertEqual("daniel", f.Name)
		
		// add to set
		let _ = try! root.mkdir(name: "conflict")
		try! root.add(folder: f)
		
		// rename wihtout conflict while in a folder
		XCTAssertNoThrow(try f.setName(name: "not conflicting"))
		XCTAssertEqual("not conflicting", f.Name)
		
		// rename with conflict
		XCTAssertThrowsError(try f.setName(name: "conflict"))
	}
	
	func testSetSynopsis() {
		let synopsis = "This is the description."
		root.setSynopsis(synopsis: synopsis)
		XCTAssertEqual(synopsis, root.Synopsis)
	}
	
	func testContainsFolder() {
		let child = try! root.mkdir(name: "child")
		
		// should find it
		XCTAssertTrue(root.contains(folder: child))
		
		// should fail
		let other = Novella.Folder(name: "other")
		XCTAssertFalse(root.contains(folder: other))
	}
	
	func testContainsFolderName() {
		let name = "folder name"
		let _ = try! root.mkdir(name: name)
		
		XCTAssertTrue(root.containsFolderName(name: name))
		XCTAssertFalse(root.containsFolderName(name: "not existing"))
	}
	
	func testAddFolder() {
		// cannot add self
		XCTAssertThrowsError(try root.add(folder: root))
		
		// cannot add to existing parent
		let child = try! root.mkdir(name: "child")
		XCTAssertThrowsError(try root.add(folder: child))
		
		// cannot add existing name
		XCTAssertThrowsError(try root.add(folder: Folder(name: child.Name)))
		
		// otherwise all good
		let other = Novella.Folder(name: "other")
		XCTAssertNoThrow(try root.add(folder: other))
		XCTAssertEqual(other._parent, root)
		XCTAssertTrue(root.contains(folder: other))
	}
	
	func testRemoveFolder() {
		let child = Novella.Folder(name: "child")
		try! root.add(folder: child)
		
		// remove should be good
		XCTAssertTrue(root.contains(folder: child))
		XCTAssertNoThrow(try root.remove(folder: child))
		XCTAssertFalse(root.contains(folder: child))
		XCTAssertNil(child._parent)
		
		// remove nonexistent folder should fail
		let other = Novella.Folder(name: "other")
		XCTAssertThrowsError(try root.remove(folder: other))
	}
	
	func testHasDescendantFolder() {
		// TODO
	}
	
	func testMkdir() {
		// TODO
	}
	
	// MARK: Variables
	func testContainsVariable() {
		let child = try! root.mkvar(name: "child", type: .boolean)
		
		// should find it
		XCTAssertTrue(root.contains(variable: child))
		
		// should fail
		let other = Novella.Variable(name: "other", type: .boolean)
		XCTAssertFalse(root.contains(variable: other))
	}
	
	func testContainsVariableName() {
		let name = "variable name"
		let _ = try! root.mkvar(name: name, type: .boolean)
		
		XCTAssertTrue(root.containsVariableName(name: name))
		XCTAssertFalse(root.containsVariableName(name: "not existing"))
	}
	
	func testAddVariable() {
		// cannot add to existing parent
		let child = try! root.mkvar(name: "child", type: .boolean)
		XCTAssertThrowsError(try root.add(variable: child))
		
		// cannot add existing name
		XCTAssertThrowsError(try root.add(variable: Variable(name: child.Name, type: .boolean)))
		
		// otherwise all good
		let other = Novella.Variable(name: "other", type: .boolean)
		XCTAssertNoThrow(try root.add(variable: other))
		XCTAssertEqual(other._folder, root)
		XCTAssertTrue(root.contains(variable: other))
	}
	
	func testRemoveVariable() {
		let child = Novella.Variable(name: "child", type: .boolean)
		try! root.add(variable: child)
		
		// remove should be good
		XCTAssertTrue(root.contains(variable: child))
		XCTAssertNoThrow(try root.remove(variable: child))
		XCTAssertFalse(root.contains(variable: child))
		XCTAssertNil(child._folder)
		
		// remove nonexistent folder should fail
		let other = Novella.Variable(name: "other", type: .boolean)
		XCTAssertThrowsError(try root.remove(variable: other))
	}
	
	func testMkvar() {
		// TODO
	}
}
