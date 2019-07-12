//
//  SearchedTableviewCell.swift
//  SearchBar
//
//  Created by SokJinYoung on 07/07/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

import UIKit
import RxSwift

let rowHeight: CGFloat = 40
let reuseCellIdentifier = "SearchedTableviewCell"

class SearchedTableviewCell: UITableViewCell {
    @IBOutlet weak var searchedWordLabel: UILabel!
    @IBOutlet weak var delButton: UIButton!
    
    var bag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
}
