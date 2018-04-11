//
//  VariableSetTests.swift
//  novellaTests
//
//  Created by Daniel Green on 10/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import XCTest
@testable import Novella

class VariableSetTests: XCTestCase {
	func testSetName() {
		let setA = Novella.VariableSet(name: "daniel")
		
		// change the name without being in a parent set should work
		XCTAssertNoThrow(try setA.setName(name: "zak"))
		XCTAssertEqual("zak", setA.Name)
		
		let setB = Novella.VariableSet(name: "mengna")
		let parent = Novella.VariableSet(name: "egg")
		do {
			try parent.addSet(set: setA)
			try parent.addSet(set: setB)
		} catch { XCTFail() }
		
		// change name while in a parent set without conflict should work
		XCTAssertNoThrow(try setA.setName(name: "egg"))
		XCTAssertEqual("egg", setA.Name)
		
		// change name while in parent set with conflict should fail
		XCTAssertThrowsError(try setA.setName(name: setB.Name))
	}
	
	func testSetSynopsis() {
		let set = Novella.VariableSet(name: "test")
		let synopsis = "This is the description of the variable."
		set.setSynopsis(synopsis: synopsis)
		XCTAssertEqual(synopsis, set.Synopsis)
	}
	
	func testContainsSet() {
		let parent = Novella.VariableSet(name: "parent")
		let child = Novella.VariableSet(name: "inside")
		do {
			try parent.addSet(set: child)
		} catch { XCTFail() }
		
		XCTAssertTrue(parent.containsSet(name: child.Name))
		XCTAssertFalse(parent.containsSet(name: "thisNameIsNotIn"))
	}
	
	func testAddSet() {
		let parent = Novella.VariableSet(name: "parent")
		let child = Novella.VariableSet(name: "child")
		
		// adding should work just fine w/o any clashes
		XCTAssertNoThrow(try parent.addSet(set: child))
		XCTAssertTrue(parent.containsSet(name: child.Name))
		
		// should fail if we add a set with the same name
		let conflict = Novella.VariableSet(name: child.Name)
		XCTAssertThrowsError(try parent.addSet(set: conflict))
	}
	
	func testRemoveSet() {
		let parent = Novella.VariableSet(name: "parent")
		let child = Novella.VariableSet(name: "child")
		do {
			try parent.addSet(set: child)
		} catch { XCTFail() }
		
		// remove set that exists should work
		XCTAssertTrue(parent.containsSet(name: child.Name))
		XCTAssertNoThrow(try parent.removeSet(name: child.Name))
		XCTAssertFalse(parent.containsSet(name: child.Name))
		XCTAssertThrowsError(try parent.removeSet(name: child.Name))
		
		// remove set that doesn't exist should fail
		XCTAssertThrowsError(try parent.removeSet(name: "thisSetDoesntExist"))
	}
	
	func testGetSet() {
		let parent = Novella.VariableSet(name: "parent")
		let child = Novella.VariableSet(name: "child")
		do {
			try parent.addSet(set: child)
		} catch { XCTFail() }
		
		// get existing set
		if let get = try? parent.getSet(name: child.Name) {
			// compare to set for certainty
			XCTAssertEqual(get.Name, child.Name)
		} else {
			XCTFail()
		}
		
		// get set that doesn't exist
		XCTAssertThrowsError(try parent.getSet(name: "doesntExist"))
	}
	
	func testContainsVariable() {
		let parent = Novella.VariableSet(name: "set")
		let variable = Novella.Variable(name: "var", type: .boolean)
		do {
			try parent.addVariable(variable: variable)
		} catch { XCTFail() }
		
		XCTAssertTrue(parent.containsVariable(name: variable.Name))
		XCTAssertFalse(parent.containsVariable(name: "thisNameIsNotIn"))
	}
	
	func testAddVariable() {
		let parent = Novella.VariableSet(name: "parent")
		let variable = Novella.Variable(name: "var", type: .boolean)
		
		// adding should work just fine w/o any clashes
		XCTAssertNoThrow(try parent.addVariable(variable: variable))
		XCTAssertTrue(parent.containsVariable(name: variable.Name))

		// should fail if we add a variable with the same name
		let conflict = Novella.Variable(name: variable.Name, type: .boolean)
		XCTAssertThrowsError(try parent.addVariable(variable: conflict))
	}
	
	func testRemoveVariable() {
		let parent = Novella.VariableSet(name: "parent")
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
		let parent = Novella.VariableSet(name: "parent")
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
