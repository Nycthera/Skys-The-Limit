//
//  Tip.swift
//  Skys The Limit
//
//  Created by Hailey Tan on 30/11/25.
//

import SwiftUI
import TipKit

//struct Tippy: Tip {
//    var title: Text {
//        Text("Tippyity")
//    }
//    var message: Text? {
//        Text("Add new tip")
//    }
//    var image: Image? {
//        Image(systemName: "paintpalette")
//    }
//    
//    var rules: [Rule] {
//         
//    }
//}

//pop
struct DeleteConstellation: Tip {
    var title: Text {
        Text("Delete Constellation")
    }
    var message: Text? {
        Text("Press and hold to delete constellation")
    }
    var image: Image? {
        Image(systemName: "trash")
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
        Text("Tap on an equation to edit it")
    }
    var image: Image? {
        Image(systemName: "hand.tap")
    }
    
    var rules: [Rule] {
         
    }
}

struct StarCoordinates: Tip {
    var title: Text {
        Text("Edit Equation")
    }
    var message: Text? {
        Text("Tap on a star to see its coordinates")
    }
    var image: Image? {
        Image(systemName: "star.fill")
    }
    
    var rules: [Rule] {
         
    }
}

struct AddEquation: Tip {
    var title: Text {
        Text("Add New Equation")
    }
    var message: Text? {
        Text("Press this button to add a new equation to the constellation")
    }
    var image: Image? {
        Image(systemName: "pencil.and.scribble")
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
