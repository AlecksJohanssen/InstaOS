//
//  PhotoViewDetailController.swift
//  First IOS App
//
//  Created by Alecks Johanssen on 4/12/17.
//  Copyright © 2017 Alecks Johanssen. All rights reserved.
//

import UIKit

class PhotoViewDetailController: UIViewController {

    var photo: NSDictionary! {
        didSet {
            print(photo)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
    }
}
