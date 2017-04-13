//
//  ViewController.swift
//  First IOS App
//
//  Created by Alecks Johanssen on 3/27/17.
//  Copyright © 2017 Alecks Johanssen. All rights reserved.
//

import UIKit
import AFNetworking


class PhotosViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    var photos = [NSDictionary]()
    var name = ""
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 320;
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let userId = "3021318827"
        let accessToken = "3021318827.1677ed0.e40de3cbc0be4e4cb64e102f79a61368"
        let url = URL(string: "https://api.instagram.com/v1/users/\(userId)/media/recent/?access_token=\(accessToken)")
        print("Test")
        if let url = url {
            let request = URLRequest(
                url: url,
                cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
                timeoutInterval: 10)
            let session = URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: nil,
                delegateQueue: OperationQueue.main)
            print("Blah")
            let task = session.dataTask(
                with: request,
                completionHandler: { (dataOrNil, response, error ) in
                if let data = dataOrNil {
                    if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        if let photoData = responseDictionary["data"] as? [NSDictionary] {
                            self.photos = photoData
                            self.tableView.reloadData()
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextScene = segue.destination as! PhotoViewDetailController
        var indexPath = tableView.indexPath(for: sender as! UITableViewCell)
        let selectedScene = photos[(indexPath?.row)!]
        nextScene.photo = selectedScene
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRow")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("deselect")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.coderschool.TableViewCell", for: indexPath) as! TableViewCell
//        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.data = photos[indexPath.row] as NSDictionary
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

