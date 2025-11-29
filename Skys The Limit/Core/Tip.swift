//
//  Tip.swift
//  Skys The Limit
//
//  Created by Hailey Tan on 30/11/25.
//

import SwiftUI
import TipKit

struct Tippy: Tip {
    var title: Text {
        Text("Tippyity")
    }
    var message: Text? {
        Text("Add new tip")
    }
    var image: Image? {
        Image(systemName: "paintpalette")
    }
    
    var rules: [Rule] {
         
    }
}

//pop
struct DeleteConstellation: Tip {
    var title: Text {
        Text("Delete Constellation")
    }
    var message: Text? {
        Text("Press and hold to delete constellation")
    }
    var image: Image? {
        Image(systemName: "paintpalette")
    }
    
    var rules: [Rule] {
         
    }
}

//tipview
struct EditEquation: Tip {
    var title: Text {
        Text("Edit Equation")
    }
    var message: Text? {
        Text("Press on an equation to edit it")
    }
    var image: Image? {
        Image(systemName: "paintpalette")
    }
    
    var rules: [Rule] {
         
    }
}


//always initialise the tip like let ... = ...
//popover tip v view tip
//    .popoverTip(Tippy)
//TipView(Tippy)
//to customise its .tip and everything will show up
 
//add dismiss when user performs the action
