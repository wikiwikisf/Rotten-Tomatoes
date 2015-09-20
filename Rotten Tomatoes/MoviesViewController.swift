//
//  MoviesViewController.swift
//  Rotten Tomatoes
//
//  Created by Vicki Chun on 9/15/15.
//  Copyright © 2015 Vicki Grospe. All rights reserved.
//

import UIKit
import AFNetworking
import SwiftLoader

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var networkImageView: UIImageView!
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Renders spinner until movies are fetched
        SwiftLoader.show(animated: true)
 
        requestMovies()
        addRefreshControl()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 138
        networkImageView.image = UIImage(named: "makefg.php")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestMovies() {
        let cachedDataUrlString = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
        let request = NSURLRequest(URL: cachedDataUrlString);
        let sess = NSURLSession.sharedSession()
        
        sess.dataTaskWithRequest(request, completionHandler: {(data: NSData?, response: NSURLResponse?,
            error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if let error = error {
                    if (error.domain == "NSURLErrorDomain") {
                        print("network error")
                        self.networkErrorView.hidden = false
                    }
                    SwiftLoader.hide()
                    return
                }
                else {
                    self.networkErrorView.hidden = true
                    do {
                        let dictionary = try NSJSONSerialization.JSONObjectWithData(data!,
                            options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
                        if let dictionary = dictionary {
                            SwiftLoader.hide()
                            self.movies = dictionary["movies"] as? [NSDictionary]
                            self.tableView.reloadData()
                        }
                        //print(dictionary)
                    } catch let error as NSError {
                        print("error parsing json" + error.description)
                    }
                }
            }
        }).resume()
    }
    
    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            // Refresh and make another request for movies
            self.requestMovies()
            self.refreshControl.endRefreshing()
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        
        let lowResString =  movie.valueForKeyPath("posters.thumbnail") as! String
        var highResString = lowResString
        let range = lowResString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            highResString =
                lowResString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        
        var placeholderImage: UIImage?
        let lowResUrl = NSURL(string: lowResString)!
        if let lowResData = NSData(contentsOfURL: lowResUrl) {
            placeholderImage = UIImage(data: lowResData)
        }
        let highResUrl = NSURL(string: highResString)!
        
        // Fade in high-res images, show low-res images initially
        // TODO: should failure here render a network error?
        cell.posterView.setImageWithURLRequest(NSURLRequest(URL: highResUrl), placeholderImage: placeholderImage,
            success:nil, failure: nil)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! MovieCell
        let indexPath = tableView.indexPathForCell(cell)!
        let movie = movies![indexPath.row]
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }

}
