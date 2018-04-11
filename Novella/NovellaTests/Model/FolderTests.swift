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
			try parent.addFolder(folder: setA)
			try parent.addFolder(folder: setB)
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
			try parent.addFolder(folder: child)
		} catch { XCTFail() }
		
		XCTAssertTrue(parent.containsFolder(name: child.Name))
		XCTAssertFalse(parent.containsFolder(name: "thisNameIsNotIn"))
	}
	
	func testAddSet() {
		let parent = Novella.Folder(name: "parent")
		let child = Novella.Folder(name: "child")
		
		// adding should work just fine w/o any clashes
		XCTAssertNoThrow(try parent.addFolder(folder: child))
		XCTAssertTrue(parent.containsFolder(name: child.Name))
		
		// should fail if we add a set with the same name
		let conflict = Novella.Folder(name: child.Name)
		XCTAssertThrowsError(try parent.addFolder(folder: conflict))
	}
	
	func testRemoveSet() {
		let parent = Novella.Folder(name: "parent")
		let child = Novella.Folder(name: "child")
		do {
			try parent.addFolder(folder: child)
		} catch { XCTFail() }
		
		// remove set that exists should work
		XCTAssertTrue(parent.containsFolder(name: child.Name))
		XCTAssertNoThrow(try parent.removeFolder(name: child.Name))
		XCTAssertFalse(parent.containsFolder(name: child.Name))
		XCTAssertThrowsError(try parent.removeFolder(name: child.Name))
		
		// remove set that doesn't exist should fail
		XCTAssertThrowsError(try parent.removeFolder(name: "thisSetDoesntExist"))
	}
	
	func testGetSet() {
		let parent = Novella.Folder(name: "parent")
		let child = Novella.Folder(name: "child")
		do {
			try parent.addFolder(folder: child)
		} catch { XCTFail() }
		
		// get existing set
		if let get = try? parent.getFolder(name: child.Name) {
			// compare to set for certainty
			XCTAssertEqual(get.Name, child.Name)
		} else {
			XCTFail()
		}
		
		// get set that doesn't exist
		XCTAssertThrowsError(try parent.getFolder(name: "doesntExist"))
	}
	
	func testContainsVariable() {
		let parent = Novella.Folder(name: "set")
		let variable = Novella.Variable(name: "var", type: .boolean)
		do {
			try parent.addVariable(variable: variable)
		} catch { XCTFail() }
		
		XCTAssertTrue(parent.containsVariable(name: variable.Name))
		XCTAssertFalse(parent.containsVariable(name: "thisNameIsNotIn"))
	}
	
	func testAddVariable() {
		let parent = Novella.Folder(name: "parent")
		let variable = Novella.Variable(name: "var", type: .boolean)
		
		// adding should work just fine w/o any clashes
		XCTAssertNoThrow(try parent.addVariable(variable: variable))
		XCTAssertTrue(parent.containsVariable(name: variable.Name))

		// should fail if we add a variable with the same name
		let conflict = Novella.Variable(name: variable.Name, type: .boolean)
		XCTAssertThrowsError(try parent.addVariable(variable: conflict))
	}
	
	func testRemoveVariable() {
		let parent = Novella.Folder(name: "parent")
		let variable = Novella.Variable(name: "var", type: .boolean)
		do {
			try parent.addVariable(variable: variable)
		} catch { XCTFail() }
		
		// remove variable that exists should work
		XCTAssertTrue(parent.containsVariable(name: variable.Name))
		XCTAssertNoThrow(try parent.removeVariable(name: variable.Name))
		XCTAssertFalse(parent.containsVariable(name: variable.Name))
		XCTAssertThrowsError(try parent.removeVariable(name: variable.Name))
		
		// remove variable that doesn't exist should fail
		XCTAssertThrowsError(try parent.removeVariable(name: "thisSetDoesntExist"))
	}
	
	func testGetVariable() {
		let parent = Novella.Folder(name: "parent")
		let variable = Novella.Variable(name: "var", type: .boolean)
		do {
			try parent.addVariable(variable: variable)
		} catch { XCTFail() }
		
		// get existing variable
		if let get = try? parent.getVariable(name: variable.Name) {
			// compare to variable for certainty
			XCTAssertEqual(get.Name, variable.Name)
		} else {
			XCTFail()
		}
		
		// get variable that doesn't exist
		XCTAssertThrowsError(try parent.getVariable(name: "doesntExist"))
	}
}
