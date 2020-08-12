//
//  Cat.swift
//  cat-gallery
//
//  Created by Otávio Souza on 12/08/20.
//  Copyright © 2020 otavioses. All rights reserved.
//

import UIKit
import SwiftyJSON

class Cat: NSObject {
    var link = String()
    var image: UIImage?
    init(json: JSON) {
        self.link = json["link"].stringValue
    }
    
    func set(image: UIImage) {
        self.image = image
    }
}
