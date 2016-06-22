//  DEMO APP

//  SWIFT 2

import Cocoa

class Downloader: NSObject {
    
    let colorsAPIHexURL = "http://www.thecolorapi.com/id?hex="

    func makeSchemeURL(hex: String) -> String {
        return "http://www.thecolorapi.com/scheme?hex=\(hex)&mode=triad&count=3"
    }

    func download(url: String, completion: (data: Data) -> Void) {
        guard let validURL = URL(string: url) else {
            NSLog("%@", "Invalid URL")
            return
        }
        let session = URLSession.shared()
        let request = URLRequest(url: validURL)
        session.dataTask(with: request) { (data, response, downloadError) -> Void in
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
        }.resume()
    }

    func JSONDataToDictionary(data: Data?) -> [String: AnyObject]? {
        do {
            guard let dat = data,
                json = try JSONSerialization.jsonObject(with: dat, options: []) as? [String: AnyObject]
                else {
                    throw DemoAppError.couldNotProcessDownloadedData
            }
            return json
        } catch let demoAppError as DemoAppError {
            print(demoAppError)
            return nil
        } catch let error as NSError {
            print(error.debugDescription)
            return nil
        }
    }

    func getName(for color: NSColor, completionHandler: (name: String) -> Void) {
        guard let compos = color.componentsCSS()?.clean else {
            return
        }
        let url = colorsAPIHexURL + compos
        download(url: url, completion: { (data) -> Void in
            guard let json = self.JSONDataToDictionary(data: data),
                dic = json["name"] as? [String:AnyObject],
                name = dic["value"] as? String
                else {
                    return
            }
            completionHandler(name: name)
        })
    }

}
