//
//  NVTransfer.swift
//  Novella
//
//  Created by Daniel Green on 11/04/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

public class NVTransfer {
	// MARK: - Variables -
	private var _manager: NVStoryManager
	private var _destination: NVObject?
	private var _function: NVFunction
	
	// MARK: - Properties -
	public var Destination: NVObject? {
		get{ return _destination }
		set {
			if newValue != nil && !(newValue!.isLinkable()) {
				NVLog.log("Could not set Transfer's destination as Object was not linkable (\(newValue!.UUID.uuidString)).", level: .warning)
				return
			}
			_destination = newValue
			
			NVLog.log("Transfer destination set to (\(_destination?.UUID.uuidString ?? "nil")).", level: .info)
			_manager.Delegates.forEach{$0.onStoryTransferDestinationChanged(transfer: self, dest: _destination)}
		}
	}
	public var Function: NVFunction {
		get{ return _function }
	}
	
	// MARK: - Initialization -
	init(manager: NVStoryManager) {
		self._manager = manager
		self._destination = nil
		self._function = NVFunction(manager: manager)
	}
}
