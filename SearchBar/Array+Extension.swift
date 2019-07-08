//
//  Array+Extensions.swift
//  SearchBar
//
//  Created by SokJinYoung on 08/07/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

import Foundation


extension Array{
    mutating func moveIndex(from: Int, to: Int){
        let element = self.remove(at: from)
        self.insert(element, at: to)
    }
}

