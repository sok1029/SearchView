//
//  UIView+Extension.swift
//  smartlearning2
//
//  Created by Young Su Kim on 20/02/2019.
//  Copyright © 2019 Young Su Kim. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import RxCocoa

extension UIView {
    func addSubviewBySameConstraint(subView: UIView){
        self.addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        subView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        subView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        subView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}
