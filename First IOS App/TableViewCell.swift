//
//  TableViewCell.swift
//  First IOS App
//
//  Created by Alecks Johanssen on 3/29/17.
//  Copyright © 2017 Alecks Johanssen. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class TableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var imgView: UIImageView!
    
    var data: NSDictionary! {
        didSet {
            let data_key = data["images"] as? NSDictionary
            print(data_key)
            let image_url = data_key?["standard_resolution"] as? NSDictionary
            let url = URL(string: image_url!["url"] as! String)
            Alamofire.request(url!).responseImage { response in
                debugPrint(response)
                if let image = response.result.value {
                    let size = CGSize(width: 351.0, height: 351.0)
                    let scaledImage = image.af_imageAspectScaled(toFit: size)
                    self.imgView.image = scaledImage
                }
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
