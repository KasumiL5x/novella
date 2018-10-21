//
//  Colors.swift
//  novella
//
//  Created by dgreen on 26/08/2018.
//  Copyright © 2018 dgreen. All rights reserved.
//

import Cocoa

class Colors {
    // VariablesViewController/OutlinerViewController
    static let TableRowEven = NSColor.fromHex("#FEFEFE")
    static let TableRowOdd = NSColor.fromHex("#F9F9F9")
    // VariablesTableRowView
    static let TableRowSelected = NSColor.fromHex("#739cde")
    static let TableGroupRowSelected = NSColor.fromHex("#739cde")
    static let TableGroupRowDeselected = NSColor.fromHex("#f7f7f7")
    
    // list of all colors
    // 000000
    // 3c3c3c
    // FAFAFA
    // FFFFFF
    // 4ecca3
    // 4B9CFD
    // 87e5da
    // f34949
    // dfedff
    // acd3ff
    // D6D6D6
    // white@0.8*0.2
    
    // transfer
    //   - outline color: NSColor.black
    //   - dest color (w/o connection): NSColor.fromHex("#3c3c3c")
    // link
    //   - fill color: NSColor.fromHex("#3c3c3c").withAlphaComponent(0.05)
    // board
    //   - fill color: NSColor.fromHex("#FAFAFA")
    // canvas object
    //   - default color: NSColor.fromHex("#3c3c3c")
    // canvas node
    //   - name label:    NSColor.fromHex("#3C3C3C")
    //   - content label: NSColor.fromHex("#3C3C3C")
    //   - bg gradient:   [NSColor.fromHex("#FAFAFA"), NSColor.fromHex("#FFFFFF")]
    //   - entry point:   NSColor.fromHex("#4ecca3")
    //   - primed:        NSColor.fromHex("#4B9CFD")
    //   - selected:      NSColor.fromHex("#4B9CFD")
    // canvas dialog
    //   - color: NSColor.fromHex("#A8E6CF")
    // canvas delivery
    //   - color: NSColor.fromHex("#FFA35F")
    // canvas branch
    //   - label color:            NSColor.fromHex("#3C3C3C")
    //   - true transfer outline:  NSColor.fromHex("#87e5da")
    //   - false transfer outline: NSColor.fromHex("#f34949")
    //   - bg gradient:            [NSColor.fromHex("#FAFAFA"), NSColor.fromHex("#FFFFFF")]
    //   - primed:                 NSColor.fromHex("#4B9CFD")
    //   - selected:               NSColor.fromHex("#4B9CFD")
    // canvas grid
    //   - bg color:   NSColor.fromHex("#dfedff")
    //   - line color: NSColor.fromHex("#acd3ff")
    // canvas marquee
    //   - outline: NSColor.fromHex("#D6D6D6")
    //   - fill: NSColor(calibratedWhite: 0.8, alpha: 0.2)
}
