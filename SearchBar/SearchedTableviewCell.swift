//
//  SearchedTableviewCell.swift
//  SearchBar
//
//  Created by SokJinYoung on 07/07/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

import UIKit

let rowHeight :CGFloat = 40
let reuseCellIdentifier = "SearchedTableviewCell"

class SearchedTableviewCell: UITableViewCell {
    
    @IBOutlet weak var searchedWordLabel: UILabel!
    
    static func loadWithOwner(owner: Any) -> Any?{
        
        let objs: [Any]? = Bundle.main.loadNibNamed(reuseCellIdentifier, owner: owner, options: nil)
        
        if let objs = objs{
            for obj: Any in objs{
                if type(of: obj.self) == type(of: self){
                    return obj
                }
            }
        }
        return nil
    }
}
