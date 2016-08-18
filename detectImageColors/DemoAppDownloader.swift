// DEMO APP

import Cocoa

class Downloader {
    
    let colorsAPIHexURL = "http://www.thecolorapi.com/id?hex="

    func makeSchemeURL(hex: String) -> String {
        return "http://www.thecolorapi.com/scheme?hex=\(hex)&mode=triad&count=3"
    }

    func download(url: URL, completion: @escaping (_ data: Data) -> Void) {
        let session = URLSession.shared
        let request = URLRequest(url: url)
        session.dataTask(with: request) { (data, response, downloadError) -> Void in
            guard let dat = data, downloadError == nil else {
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
            completion(dat)
        }.resume()
    }

    func JSONDataToDictionary(data: Data?) -> [String: AnyObject]? {
        do {
            guard let dat = data,
                let json = try JSONSerialization.jsonObject(with: dat, options: []) as? [String: AnyObject]
                else {
                    throw DemoAppError.couldNotProcessDownloadedData
            }
            return json
        } catch let demoAppError as DemoAppError {
            print(demoAppError)
            return nil
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func getName(for color: NSColor, completionHandler: @escaping (_ name: String) -> Void) {
        guard let compos = color.componentsCSS()?.clean else {
            return
        }
        let url = colorsAPIHexURL + compos
        guard let validURL = URL(string: url) else {
            NSLog("%@", "Invalid URL")
            return
        }
        download(url: validURL, completion: { (data) -> Void in
            guard let json = self.JSONDataToDictionary(data: data),
                let dic = json["name"] as? [String:AnyObject],
                let name = dic["value"] as? String
                else {
                    return
            }
            completionHandler(name)
        })
    }

}
