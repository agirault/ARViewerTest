//
//  Extensions.swift
//  ARViewerTest
//
//  Created by Alexis Girault on 10/27/17.
//  Copyright © 2017 Alexis Girault. All rights reserved.
//

import UIKit

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
