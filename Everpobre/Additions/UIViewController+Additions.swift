//
//  UIViewController+Additions.swift
//  Everpobre
//
//  Created by luis gomez alonso on 7/4/18.
//  Copyright © 2018 luis gomez alonso. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func wrappedInNavigation() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
}
