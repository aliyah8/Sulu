//
//  Definition.swift
//  KDCalendar
//
//  Created by Aliya Tyshkanbayeva on 7/15/16.
//  Copyright © 2016 Karmadust. All rights reserved.
//

import Foundation

class Definition {
    var name: String?
    var description: String?
var image: String?
    
    init(name: String, description: String, image: String) {
        self.name = name
        self.description = description
     self.image = image
    }
}