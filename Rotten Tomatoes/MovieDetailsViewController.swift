//
//  MovieDetailsViewController.swift
//  Rotten Tomatoes
//
//  Created by Vicki Chun on 9/17/15.
//  Copyright © 2015 Vicki Grospe. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String
        synopsisLabel.sizeToFit()
        fadeInImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x,
                y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
    
    func fadeInImage() {
        let lowResString =  movie.valueForKeyPath("posters.thumbnail") as! String
        var highResString = lowResString
        
        // Convert to high-res image
        let range = lowResString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            highResString = lowResString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }

        var placeholderImage: UIImage?
        let lowResUrl = NSURL(string: lowResString)!
        if let lowResData = NSData(contentsOfURL: lowResUrl) {
            placeholderImage = UIImage(data: lowResData)
        }
        let highResUrl = NSURL(string: highResString)!
        let highResURLRequest = NSURLRequest(URL: highResUrl,
            cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 30)
        // Fade in high-res image, show low-res image initially
        posterImageView.setImageWithURLRequest(highResURLRequest, placeholderImage: placeholderImage,
            success:nil, failure: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
