//
//  SwitchOptionViewController.swift
//  novella
//
//  Created by dgreen on 19/10/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import AppKit

class SwitchOptionViewController: NSViewController {
	@IBOutlet private weak var _boolField: NSPopUpButton!
	@IBOutlet private weak var _textField: NSTextField!
	@IBOutlet weak var _typeField: NSPopUpButton!
	
	private var _intFormatter = NumberFormatter()
	private var _dubFormatter = NumberFormatter()
	private var _option: NVSwitchOption?
	
	func setup(option: NVSwitchOption) {
		_option = option
		
		_intFormatter.numberStyle = .decimal
		_dubFormatter.numberStyle = .decimal
		_intFormatter.generatesDecimalNumbers = false
		_dubFormatter.generatesDecimalNumbers = true
		_intFormatter.minimumFractionDigits = 0
		_dubFormatter.minimumFractionDigits = 0
		_dubFormatter.maximumFractionDigits = 3
		_intFormatter.maximumFractionDigits = 0
		_intFormatter.alwaysShowsDecimalSeparator = false
		_dubFormatter.alwaysShowsDecimalSeparator = true
		_intFormatter.allowsFloats = false
		_dubFormatter.allowsFloats = true
		
		switch option.value.Raw.type {
		case .boolean:
			_boolField.isHidden = false
			_textField.isHidden = true
			_boolField.selectItem(withTitle: option.value.Raw.asBool ? "True" : "False")
			_typeField.selectItem(withTitle: "Boolean")
		case .integer:
			_boolField.isHidden = true
			_textField.isHidden = false
			_textField.formatter = _intFormatter
			_textField.stringValue = String(option.value.Raw.asInt)
			_typeField.selectItem(withTitle: "Integer")
		case .double:
			_boolField.isHidden = true
			_textField.isHidden = false
			_textField.formatter = _dubFormatter
			_textField.stringValue = String(option.value.Raw.asDouble)
			_typeField.selectItem(withTitle: "Double")
		}
	}
	
	@IBAction private func onBoolChange(_ sender: NSPopUpButton) {
		if let option = _option, let title = sender.selectedItem?.title, option.value.Raw.type == .boolean {
				option.value = NVValue(.boolean(title == "True"))
		}
	}
	
	@IBAction private func onTextChanged(_ sender: NSTextField) {
		if let option = _option {
			if option.value.Raw.type == .integer {
				option.value = NVValue(.integer(Int32(sender.stringValue) ?? 0))
			}
			if option.value.Raw.type == .double {
				option.value = NVValue(.double(Double(sender.stringValue) ?? 0.0))
			}
		}
	}
	
	@IBAction func onTypeChanged(_ sender: NSPopUpButton) {
		guard let option = _option else {
			return
		}
		
		switch sender.titleOfSelectedItem {
		case "Boolean":
			option.value = NVValue(.boolean(option.value.Raw.asBool))
		case "Integer":
			option.value = NVValue(.integer(option.value.Raw.asInt))
		case "Double":
			option.value = NVValue(.double(option.value.Raw.asDouble))
		default:
			break
		}
		
		// run setup again to reload everything
		setup(option: option)
	}
}
