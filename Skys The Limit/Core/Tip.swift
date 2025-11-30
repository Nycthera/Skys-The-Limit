//
//  Tip.swift
//  Skys The Limit
//
//  Created by Hailey Tan on 30/11/25.
//

import Foundation
import TipKit

//tip view
struct DeleteConstellationTip: Tip {
    
    var title: Text {
        Text("Delete Constellation")
    }
    var message: Text? {
        Text("Press and hold to delete a constellation")
    }
    var image: Image? {
        Image(systemName: "trash")
    }
}

//pop over tip
struct EditEquationTip: Tip {
    static let editEquationEvent = Event(id: "editEquation")
    static let customConstellationViewVisitedEvent = Event(id: "customConstellationViewVisited")
    
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
        #Rule(Self.editEquationEvent) { event in
            event.donations.count == 0
        }
        
        #Rule(Self.customConstellationViewVisitedEvent) { event in
            event.donations.count > 2
        }
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
