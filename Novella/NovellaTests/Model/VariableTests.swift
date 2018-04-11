//
//  VariableSet.swift
//  novellaTests
//
//  Created by Daniel Green on 03/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

import XCTest
@testable import Novella

class VariableTests: XCTestCase {
	func testSetName() {
		let varA = Novella.Variable(name: "daniel", type: .boolean)
		
		// change the name without being in a set should work
		XCTAssertNoThrow(try varA.setName(name: "zak"))
		XCTAssertEqual("zak", varA.Name)
		
		let varB = Novella.Variable(name: "mengna", type: .integer)
		let setA = Novella.VariableSet(name: "set")
		do {
			try setA.addVariable(variable: varA)
			try setA.addVariable(variable: varB)
		} catch { XCTFail() }
		
		// change name while in a set without conflict should work
		XCTAssertNoThrow(try varA.setName(name: "egg"))
		XCTAssertEqual("egg", varA.Name)
		
		// change name while in a set with conflict should fail
		XCTAssertThrowsError(try varA.setName(name: varB.Name))
	}
	
	func testSetSynopsis() {
		let variable = Novella.Variable(name: "test", type: .boolean)
		let synopsis = "This is the description of the variable."
		variable.setSynopsis(synopsis: synopsis)
		XCTAssertEqual(synopsis, variable.Synopsis)
	}
	
	func testSetType() {
		let variable = Novella.Variable(name: "test", type: .boolean)
		variable.setType(type: .integer)
		XCTAssertEqual(Novella.DataType.integer, variable.DataType)
		XCTAssertEqual(Novella.DataType.integer.defaultValue as! Int, variable.Value as! Int)
		XCTAssertEqual(Novella.DataType.integer.defaultValue as! Int, variable.InitialValue as! Int)
	}
	
	func testSetValue() {
		let variable = Novella.Variable(name: "test", type: .boolean)
		
		// cannot set different datatype
		XCTAssertThrowsError(try variable.setValue(val: 0.5))
		XCTAssertNoThrow(try variable.setValue(val: true))
		
		// cannot set constant variable
		variable.setConstant(const: true)
		XCTAssertThrowsError(try variable.setValue(val: true))
		
		// should work if not constant and same datatype
		variable.setConstant(const: false)
		variable.setType(type: .integer)
		XCTAssertNoThrow(try variable.setValue(val: 5)) // should work
		XCTAssertThrowsError(try variable.setValue(val: 0.75)) // should fail
	}
	
	func testSetInitialValue() {
		let variable = Novella.Variable(name: "test", type: .integer)
		
		// cannot set different datatype
		XCTAssertThrowsError(try variable.setInitialValue(val: true))
		XCTAssertNoThrow(try variable.setInitialValue(val: 5))
	}
}
