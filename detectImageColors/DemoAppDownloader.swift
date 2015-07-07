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
                    NSLog("%@", response!)
                } else {
                    completion(data: data!)
                }
            }
            task!.resume()
        } else {
            NSLog("%@", "Invalid URL")
        }
    }

    func JSONDataToDictionary(data: NSData?) -> [String: AnyObject]? {
        if let data = data {
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
                return dict
            } catch let error {
                print(error)
            }
        }
        return nil
    }

    func getColorNameFromAPI(color: NSColor, completionHandler: (name: String) -> Void) {
        let url = colorsAPIHexURL + color.componentsCSS()!.clean
        download(url, completion: { (data) -> Void in
            if let json = self.JSONDataToDictionary(data) {
                if let dic = json["name"] as? [String:AnyObject] {
                    if let name = dic["value"] as? String {
                        completionHandler(name: name)
                    }
                }
            }
        })
    }

}
