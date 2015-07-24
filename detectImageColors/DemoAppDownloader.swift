//  DEMO APP

//  SWIFT 2

import Cocoa

class Downloader: NSObject {
    
    let colorsAPIHexURL = "http://www.thecolorapi.com/id?hex="

    func makeSchemeURL(hex: String) -> String {
        return "http://www.thecolorapi.com/scheme?hex=\(hex)&mode=triad&count=3"
    }

    func download(url: String, completion: (data: NSData) -> Void) {
        let session = NSURLSession.sharedSession()
        if let validURL = NSURL(string: url) {
            let request = NSURLRequest(URL: validURL)
            let task = session.dataTaskWithRequest(request) { (data, response, downloadError) -> Void in
                if let error = downloadError {
                    NSLog("%@", error.localizedDescription)
                    if let rp = response {
                        NSLog("%@", rp)
                    }
                } else {
                    //NSLog("%@", "NSURLSession completed")
                    completion(data: data!)
                }
            }
            //NSLog("%@", "NSURLSession started")
            task!.resume()
        } else {
            NSLog("%@", "Invalid URL")
        }
    }

    func JSONDataToDictionary(data: NSData?) -> [String: AnyObject]? {
        guard let dat = data else { return nil }
        do {
            return try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? [String: AnyObject]
        } catch {
            print(error)
        }
        return nil
    }

    func getColorNameFromAPI(color: NSColor, completionHandler: (name: String) -> Void) {
        let compos = color.componentsCSS()!.clean
        let url = colorsAPIHexURL + compos
        download(url, completion: { (data) -> Void in
            if let json = self.JSONDataToDictionary(data) {
                if let dic = json["name"] as? [String:AnyObject] {
                    if let name = dic["value"] as? String {
                        NSLog("%@", "Downloaded API response")
                        completionHandler(name: name)
                    }
                }
            }
        })
    }

}
