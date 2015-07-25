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
        guard let validURL = NSURL(string: url) else {
            NSLog("%@", "Invalid URL")
            return
        }
        let request = NSURLRequest(URL: validURL)
        let task = session.dataTaskWithRequest(request) { (data, response, downloadError) -> Void in
            guard let dat = data where downloadError == nil else {
                if let rp = response {
                    NSLog("%@", rp)
                }
                if let error = downloadError {
                    NSLog("%@", error.localizedDescription)
                } else {
                    NSLog("%@", "Unknown error while downloading data")
                }
                return
            }
            completion(data: dat)
        }
        guard let connect = task else {
            NSLog("%@", "Unknown network error")
            return
        }
        connect.resume()
    }

    func JSONDataToDictionary(data: NSData?) -> [String: AnyObject]? {
        do {
            guard let dat = data,
                json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? [String: AnyObject]
                else { throw DemoAppError.CouldNotProcessDownloadedData
            }
            return json
        } catch let demoAppError as DemoAppError {
            print(demoAppError.rawValue)
            return nil
        } catch {
            print(error)
            return nil
        }
    }

    func getColorNameFromAPI(color: NSColor, completionHandler: (name: String) -> Void) {
        guard let compos = color.componentsCSS()?.clean else { return }
        let url = colorsAPIHexURL + compos
        download(url, completion: { (data) -> Void in
            guard let json = self.JSONDataToDictionary(data),
                dic = json["name"] as? [String:AnyObject],
                name = dic["value"] as? String
                else { return
            }
            //NSLog("%@", "Downloaded API response")
            completionHandler(name: name)
        })
    }

}
