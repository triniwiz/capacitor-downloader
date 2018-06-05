import Foundation
import Capacitor
import AFNetworking
import CoreLocation
import UIKit
/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */

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
    static var downloads:[String:URLSessionDownloadTask] = [:]
    static var downloadsData:[String:[String:Any]] = [:]
    @objc func initialize(){}

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
        let tempDir = NSURL.fileURL(withPath:NSTemporaryDirectory(),isDirectory:true)
        if (path != nil && fileName != nil) {
            fullPath =  joinPath(left:path ?? "",right: fileName ?? "");
        } else if (path == nil && fileName != nil) {
            fullPath =   joinPath(left:tempDir.path,right: fileName ?? "");
        } else if (path != nil && fileName == nil ) {
            fullPath = joinPath(left:path ?? "", right:self.generateId());
        } else {
            fullPath = joinPath(left:tempDir.path, right:self.generateId());
        }
        let configuration = URLSessionConfiguration.default;
        let download = AFURLSessionManager.init(sessionConfiguration: configuration)
        let link = NSURL.init(string:url ?? "")
        let request  = NSURLRequest.init(url: link!.absoluteURL!)
        let id = self.generateId()
        var task:URLSessionDownloadTask?
        var lastRefreshTime = 0;
        var lastBytesWritten =  Int64(0);
        task =  download.downloadTask(with: request  as URLRequest, progress: { (progress) in
            var data = JSObject()
            DispatchQueue.main.async {
                if(task != nil && task?.state == URLSessionTask.State.running){
                    let currentBytes = task?.countOfBytesReceived
                    let totalBytes = progress.totalUnitCount
                    let currentTime = Int(Date().timeIntervalSince1970 * 1000)
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
                        let updateBytes = Int(currentBytes ?? Int64(0) - lastBytesWritten);
                        speed = Int64(round(Double(updateBytes / intervalTime)));

                        data["value"] = round(progress.fractionCompleted * 100)
                        data["currentSize"] = currentBytes ?? 0
                        data["totalSize"] = totalBytes
                        data["speed"] = speed;
                        let d = DownloaderPlugin.downloadsData[id]
                        let callId = d!["call"] as! String
                        let _call = self.bridge.getSavedCall(callId)
                        _call?.success(data)
                        lastRefreshTime = Int(Date().timeIntervalSince1970 * 1000)
                        lastBytesWritten = currentBytes ?? Int64(0);

                    }


                }else if(task != nil && task?.state == URLSessionTask.State.suspended){

                }

            }
        }, destination: { (url ,urlResponse) -> URL in
            return NSURL.fileURL(withPath:fullPath)
        }) { (response, url, error) in
            if(error != nil){
                let d = DownloaderPlugin.downloadsData[id]
                let callId = d!["call"] as! String
                let _call = self.bridge.getSavedCall(callId)
                _call?.error(error?.localizedDescription ?? "")
            }else{
                if (
                    task != nil &&
                        task?.state == URLSessionTask.State.completed &&
                        task?.error == nil
                    ){
                    let d = DownloaderPlugin.downloadsData[id]
                    let callId = d!["call"] as! String
                    let _call = self.bridge.getSavedCall(callId)
                    var data = JSObject()
                    data["status"] = StatusCode.COMPLETED.rawValue
                    data["path"] = CAPFileManager.getPortablePath(uri: NSURL.fileURL(withPath:fullPath))
                    _call?.success(data)
                }
            }

        }
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
