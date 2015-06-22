//
//  DemoAppDownloader.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 22/06/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

class Downloader: NSObject {

    let colorsAPIbaseURL = "http://www.thecolorapi.com/id?hex="

    func download(url: String, completion: (data: NSData) -> Void) {
        let session = NSURLSession.sharedSession()
        if let validURL = NSURL(string: url) {
            let request = NSURLRequest(URL: validURL)
            let task = session.dataTaskWithRequest(request) { (data, response, downloadError) -> Void in
                if let error = downloadError {
                    NSLog("%@", error.localizedDescription)
                } else {
                    completion(data: data)
                }
            }
            task.resume()
        } else {
            NSLog("%@", "Invalid URL")
        }
    }

    func JSONDataToDictionary(data: NSData?) -> [String: AnyObject]? {
        var jsonError: NSError?
        if let data = data, dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? [String: AnyObject] {
            return dict
        }
        if let error = jsonError {
            NSLog("%@", error.localizedDescription)
        }
        return nil
    }

}
