//
//  Util.swift
//  SearchBar
//
//  Created by SokJinYoung on 07/07/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

import Foundation

class Util {
//MARK: Time
    static func getCurrentTime(format: String) -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
