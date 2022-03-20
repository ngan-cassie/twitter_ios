//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Hieu Ngan Nguyen on 3/10/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit
import SystemConfiguration
import Alamofire

class HomeTableViewController: UITableViewController {

    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    let myRefreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()
        // addTarget(target: self (happening in this screen), action: pull loadTweet() second time
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        print("VIEW DID APPEAR")
        loadTweets()
    }
    
    // automatically load the tweet timeline after tweeting
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        loadTweets()
//
//    }
    
    // first start with 20 tweets
    @objc func loadTweets() {
        numberOfTweets = 20
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParam = ["count": numberOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParam as [String : Any], success: {
            (tweets: [NSDictionary]) in
            // empty entire array
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            print("did reload data")
            // when done updating the table, end the spinning wheel
            self.myRefreshControl.endRefreshing()
        }, failure: {
            (Error) in
            print("couldn't retrieve tweets!")
            print(Error)
        })
    }
    
    func loadMoreTweets() {
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweets = numberOfTweets + 20
        let myParam = ["count": numberOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParam as [String : Any], success: {
            (tweets: [NSDictionary]) in
            // empty entire array
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            
            // when done updating the table, end the spinning wheel
            self.myRefreshControl.endRefreshing()
        }, failure: {
            (Error) in
            print("couldn't retrieve tweets!")
        })
    }
    
    // when reaching the end of the page, load more tweets
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        // the screen dismisses itself
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    
    // manipulate the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as? String
        cell.userNameLabel.text = user["name"] as? String
        
        let imageUrl = URL(string: ((user["profile_image_url_https"] as? String)!))
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        cell.setRetweeted(tweetArray[indexPath.row]["retweeted"] as! Bool)
       
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 150.0
//    }

}
