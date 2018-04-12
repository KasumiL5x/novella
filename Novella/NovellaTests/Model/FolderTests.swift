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
	func testSetName() {
		let setA = Novella.Folder(name: "daniel")
		
		// change the name without being in a parent set should work
		XCTAssertNoThrow(try setA.setName(name: "zak"))
		XCTAssertEqual("zak", setA.Name)
		
		let setB = Novella.Folder(name: "mengna")
		let parent = Novella.Folder(name: "egg")
		do {
			try parent.add(folder: setA)
			try parent.add(folder: setB)
		} catch { XCTFail() }
		
		// change name while in a parent set without conflict should work
		XCTAssertNoThrow(try setA.setName(name: "egg"))
		XCTAssertEqual("egg", setA.Name)
		
		// change name while in parent set with conflict should fail
		XCTAssertThrowsError(try setA.setName(name: setB.Name))
	}
	
	func testSetSynopsis() {
		let set = Novella.Folder(name: "test")
		let synopsis = "This is the description of the variable."
		set.setSynopsis(synopsis: synopsis)
		XCTAssertEqual(synopsis, set.Synopsis)
	}
	
	func testContainsSet() {
		let parent = Novella.Folder(name: "parent")
		let child = Novella.Folder(name: "inside")
		do {
			try parent.add(folder: child)
		} catch { XCTFail() }
		
		XCTAssertTrue(parent.contains(folder: child))
	}
	
	func testAddSet() {
		let parent = Novella.Folder(name: "parent")
		let child = Novella.Folder(name: "child")
		
		// adding should work just fine w/o any clashes
		XCTAssertNoThrow(try parent.add(folder: child))
		XCTAssertTrue(parent.contains(folder: child))
		
		// should fail if we add a set with the same name
		let conflict = Novella.Folder(name: child.Name)
		XCTAssertThrowsError(try parent.add(folder: conflict))
	}
	
	func testRemoveSet() {
		let parent = Novella.Folder(name: "parent")
		let child = Novella.Folder(name: "child")
		do {
			try parent.add(folder: child)
		} catch { XCTFail() }
		
		// remove set that exists should work
		XCTAssertTrue(parent.contains(folder: child))
		XCTAssertNoThrow(try parent.remove(folder: child))
		XCTAssertFalse(parent.contains(folder: child))
	}
	
	func testContainsVariable() {
		let parent = Novella.Folder(name: "set")
		let variable = Novella.Variable(name: "var", type: .boolean)
		do {
			try parent.add(variable: variable)
		} catch { XCTFail() }
		
		XCTAssertTrue(parent.contains(variable: variable))
	}
	
	func testAddVariable() {
		let parent = Novella.Folder(name: "parent")
		let variable = Novella.Variable(name: "var", type: .boolean)
		
		// adding should work just fine w/o any clashes
		XCTAssertNoThrow(try parent.add(variable: variable))
		XCTAssertTrue(parent.contains(variable: variable))

		// should fail if we add a variable with the same name
		let conflict = Novella.Variable(name: variable.Name, type: .boolean)
		XCTAssertThrowsError(try parent.add(variable: conflict))
	}
	
	func testRemoveVariable() {
		let parent = Novella.Folder(name: "parent")
		let variable = Novella.Variable(name: "var", type: .boolean)
		do {
			try parent.add(variable: variable)
		} catch { XCTFail() }
		
		// remove variable that exists should work
		XCTAssertTrue(parent.contains(variable: variable))
		XCTAssertNoThrow(try parent.remove(variable: variable))
		XCTAssertFalse(parent.contains(variable: variable))
		XCTAssertThrowsError(try parent.remove(variable: variable))
	}
}
