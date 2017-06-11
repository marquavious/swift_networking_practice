//
//  Extensions.swift
//  networking_test
//
//  Created by Marquavious on 6/9/17.
//  Copyright © 2017 Marquavious Draggon. All rights reserved.
//

import Foundation

extension Error {
    func throwCustomError(function:String){
        print("There was an error in \(function.uppercased()).ERROR: ** \(self.localizedDescription.uppercased()) ** ")
    }
}
