import Foundation
import Capacitor
import CoreLocation
import UIKit
import Alamofire


protocol DownloadData {
    var status: String {get set}
    var callback: CAPPlugin { get set}
    var path : String { get set }
}


enum StatusCode: String {
    case PENDING = "pending"
    case PAUSED = "paused"
    case DOWNLOADING = "downloading"
    case COMPLETED = "completed"
    case ERROR = "error"
}

typealias JSObject = [String:Any]
typealias JSArray = [JSObject]
@objc(DownloaderPlugin)
public class DownloaderPlugin: CAPPlugin {
    static var downloads:[String:DownloadRequest] = [:]
    static var downloadsData:[String:[String:Any]] = [:]
    
    @objc func initialize(){
        Alamofire.SessionManager.default.startRequestsImmediately = false;
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 60
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = 60
    }
    
    @objc static func setTimeout(_ call: CAPPluginCall){
        let timeout = call.getInt("timeout") ?? 60
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = Double(timeout)
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = Double(timeout)
        call.resolve()
    }
    
    public override func load() {
        self.initialize()
    }
    
    public func joinPath(left: String, right: String) -> String {
        let nsString: NSString = NSString.init(string:left);
        return nsString.appendingPathComponent(right);
    }
    
    public func generateId() -> String{
        return NSUUID().uuidString
    }
    
    @objc func createDownload(_ call: CAPPluginCall){
        let url = call.getString("url") ?? nil
        if(url == nil){
            call.reject("Url missing")
        }
        let query = call.getString("query") ?? nil
        let headers = call.getObject("headers") ?? nil
        let path = call.getString("path") ?? nil
        let fileName = call.getString("fileName") ?? nil
        var fullPath = ""
        let tempDir = FileManager.default.temporaryDirectory
        if (path != nil && fileName != nil) {
            fullPath =  joinPath(left:path ?? "",right: fileName ?? "");
        } else if (path == nil && fileName != nil) {
            fullPath =   joinPath(left:tempDir.path,right: fileName ?? "");
        } else if (path != nil && fileName == nil ) {
            fullPath = joinPath(left:path ?? "", right:self.generateId());
        } else {
            fullPath = joinPath(left:tempDir.path, right:self.generateId());
        }
        
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileURL = URL(fileURLWithPath: fullPath)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let id = self.generateId()
        
        let download = Alamofire.download(url!, to: destination)
        var task:DownloadRequest?
        var lastRefreshTime = Int64(0);
        var lastBytesWritten =  Int64(0);
        download.downloadProgress{ progress in // called on main queue by default
            if(!progress.isFinished || !progress.isPaused){
                var data = JSObject()
                let currentBytes = progress.completedUnitCount
                let totalBytes = progress.totalUnitCount
                let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
                let minTime = 100
                var speed = Int64(0)
                if (
                    currentTime - lastRefreshTime >= minTime ||
                        currentBytes == totalBytes
                    ) {
                    var intervalTime = currentTime - lastRefreshTime;
                    if (intervalTime == 0) {
                        intervalTime += 1;
                    }
                    let updateBytes = Int64(currentBytes);
                    speed = Int64(round(Double(updateBytes / intervalTime)));
                    
                    data["value"] = round(progress.fractionCompleted * 100)
                    data["currentSize"] = currentBytes
                    data["totalSize"] = totalBytes
                    data["speed"] = speed;
                    let d = DownloaderPlugin.downloadsData[id]
                    let callId = d!["call"] as! String
                    let _call = self.bridge.getSavedCall(callId)
                    _call?.success(data)
                    lastRefreshTime = Int64(Date().timeIntervalSince1970 * 1000)
                    lastBytesWritten = currentBytes ;
                }
            }
        }
        
        download
            .validate()
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success( _):
                    let d = DownloaderPlugin.downloadsData[id]
                    let callId = d!["call"] as! String
                    let _call = self.bridge.getSavedCall(callId)
                    var data = JSObject()
                    data["status"] = StatusCode.COMPLETED.rawValue
                    data["path"] = CAPFileManager.getPortablePath(host: self.bridge.getLocalUrl(), uri: response.destinationURL)
                    _call?.success(data)
                    break;
                case .failure(let error):
                    let d = DownloaderPlugin.downloadsData[id]
                    let callId = d!["call"] as! String
                    let _call = self.bridge.getSavedCall(callId)
                    _call?.error(error.localizedDescription)
                    break;
                }
            })
        
        task = download
        
        DownloaderPlugin.downloads[id] = task
        var obj = JSObject()
        obj["value"] = id
        call.resolve(obj)
    }
    @objc func start(_ call: CAPPluginCall){
        
        let id = call.getString("id") ?? nil
        if(id == nil){
            call.reject("Invalid id")
        }
        call.save()
        var object: [String:Any] = [:]
        object["call"] = call.callbackId
        object["status"] = StatusCode.PENDING
        object["path"] = nil
        DownloaderPlugin.downloadsData[id ?? ""] = object
        let task = DownloaderPlugin.downloads[id ?? ""]
        
        task?.resume()
    }
    @objc func pause(_ call: CAPPluginCall){
        let id = call.getString("id") ?? nil
        if(id == nil){
            call.reject("Invalid id")
        }
        let task = DownloaderPlugin.downloads[id ?? ""]
        task?.suspend()
        call.resolve()
    }
    @objc func resume(_ call: CAPPluginCall){
        let id = call.getString("id") ?? nil
        if(id == nil){
            call.reject("Invalid id")
        }
        let task = DownloaderPlugin.downloads[id ?? ""]
        task?.resume()
        call.resolve()
    }
    @objc func cancel(_ call: CAPPluginCall){
        let id = call.getString("id") ?? nil
        if(id == nil){
            call.reject("Invalid id")
        }
        let task = DownloaderPlugin.downloads[id ?? ""]
        task?.cancel()
        call.resolve()
    }
    @objc func getPath(_ call: CAPPluginCall){
        let id = call.getString("id") ?? nil
        let hasData = DownloaderPlugin.downloadsData[id ?? ""] as? DownloadData
        var obj = JSObject()
        if(hasData != nil && hasData?.path != nil){
            obj["value"] = hasData?.path
        }else{
            obj["value"] = nil
        }
        call.resolve(obj)
        
    }
    @objc func getStatus(_ call: CAPPluginCall){
        let id = call.getString("id") ?? nil
        let hasData = DownloaderPlugin.downloadsData[id ?? ""] as? DownloadData
        var obj = JSObject()
        if(hasData != nil && hasData?.status != nil){
            obj["value"] = hasData?.status
        }else{
            obj["value"] = StatusCode.PENDING
        }
        call.resolve(obj)
    }
}
