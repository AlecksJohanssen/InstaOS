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
    var isMoreDataLoading = false
    var isLoadingOnce = false
    var loadMoreURL: URL?
    var loadingMoreView: InfiniteScrollActivityView?
    var numberOfImageViews: Int = 20
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 320;
        super.viewDidLoad()
        loadData()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        let userId = "3021318827"
        let accessToken = "3021318827.1677ed0.e40de3cbc0be4e4cb64e102f79a61368"
        let url = URL(string: "https://api.instagram.com/v1/users/\(userId)/media/recent/?access_token=\(accessToken)")
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        let task: URLSessionTask = session.dataTask(with: request) {
            (data: Data?,
            response: URLResponse?,
            error: Error?) in
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    func delay(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableView.sectionHeaderHeight = 45
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        let labelView = UILabel(frame: CGRect(x: 50, y: 10, width: 320, height: 30))
        labelView.text = "Alecks Johanssen"
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1
        let url = URL(string: "https://scontent.cdninstagram.com/t51.2885-19/s150x150/17662850_1755198108129235_8707994940795256832_a.jpg")
        profileView.setImageWith(url!)
        headerView.addSubview(profileView)
        headerView.addSubview(labelView)
        return headerView

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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffThreshold = scrollViewContentHeight - tableView.bounds.size.height
            if(scrollView.contentOffset.y > scrollOffThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        if let loadMoreURL = loadMoreURL {
            let request = URLRequest(
                url: loadMoreURL,
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
                        if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
                            let paginationURL = responseDictionary["pagination"]
                            var pagiURL = paginationURL?["next_url"] as? String
                            self.loadMoreURL = URL(string: pagiURL!)
                            if let photoData = responseDictionary["data"] as? [NSDictionary] {
                                for item in photoData { // loop through data items
                                    let obj = item as NSDictionary
                                    self.photos.append(obj)
                                }
                                self.isMoreDataLoading = false
                                self.loadingMoreView!.stopAnimating()
                                self.tableView.reloadData()
                            }
                        }
                    }
            })
            task.resume()
        }

    }
    
    func loadData() {
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
                        if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
                            let paginationURL = responseDictionary["pagination"]
                            print(paginationURL?["next_url"])
                            var pagiURL = paginationURL?["next_url"] as? String
                            self.loadMoreURL = URL(string: pagiURL!)
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

