package co.fitcom.capacitor.Downloader;

import android.net.Uri;

import com.getcapacitor.FileUtils;
import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

import java.io.File;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import co.fitcom.fancydownloader.DownloadListenerUI;
import co.fitcom.fancydownloader.Manager;
import co.fitcom.fancydownloader.Request;


enum StatusCode {
    PENDING {
        @Override
        public String toString() {
            return "pending";
        }
    },
    PAUSED {
        @Override
        public String toString() {
            return "paused";
        }
    },
    DOWNLOADING {
        @Override
        public String toString() {
            return "downloading";
        }
    },
    COMPLETED {
        @Override
        public String toString() {
            return "completed";
        }
    },
    ERROR {
        @Override
        public String toString() {
            return "error";
        }
    },
}

class DownloadData {
    private String status = null;
    private String path = null;
    private PluginCall call = null;

    String getStatus() {
        return status;
    }

    void setStatus(String status) {
        this.status = status;
    }

    PluginCall getCallback() {
        return call;
    }

    void setCallback(PluginCall call) {
        this.call = call;
    }

    String getPath() {
        return path;
    }

    void setPath(String path) {
        this.path = path;
    }
}


@NativePlugin()
public class DownloaderPlugin extends Plugin {
    private Map<String, DownloadData> downloadsData;
    private Map<String, Request> downloadsRequest;

    class Listener extends DownloadListenerUI {

        @Override
        public void onUIProgress(String task, long currentBytes, long totalBytes, long speed) {
            DownloadData data = downloadsData.get(task);
            if (data != null) {
                JSObject object = new JSObject();
                object.put("value", (currentBytes * 100 / totalBytes));
                object.put("speed", speed);
                object.put("currentSize", currentBytes);
                object.put("totalSize", totalBytes);
                data.getCallback().success(object);
            }

        }

        @Override
        public void onUIComplete(String task) {
            DownloadData data = downloadsData.get(task);
            Request request = downloadsRequest.get(task);
            if (data != null) {
                JSObject object = new JSObject();
                object.put("status", StatusCode.COMPLETED);
                String path = FileUtils.getPortablePath(getContext(), Uri.fromFile(new File(request.getFilePath(), request.getFileName())));
                object.put("path", path);
                data.getCallback().success(object);
                downloadsData.remove(task);
                downloadsRequest.remove(task);
            }

        }

        @Override
        public void onUIError(String task, Exception e) {
            DownloadData data = downloadsData.get(task);
            if (data != null) {
                data.getCallback().reject(e.getLocalizedMessage());
            }

        }
    }

    @Override
    public void load() {
        super.load();
        Manager.init(this.getContext());
        if (downloadsData == null) {
            downloadsData = new HashMap<>();
        }
        if (downloadsRequest == null) {
            downloadsRequest = new HashMap<>();
        }
    }

    @PluginMethod()
    public void initialize(PluginCall call) {
        Manager.init(this.getContext());
    }

    @PluginMethod()
    public void createDownload(PluginCall call) {
        Manager manager = Manager.getInstance();
        String url = call.getString("url");
        String query = call.getString("query");
        JSObject headers = call.getObject("headers");
        String path = call.getString("path");
        String fileName = call.getString("fileName");
        Request request = new Request(url);
        DownloadData data = new DownloadData();
        if (query != null) {
            // TODO
        }

        if (headers != null) {
            HashMap<String, String> map = new HashMap<String, String>();
            int len = headers.length();
            Iterator<String> keys = headers.keys();
            for (int i = 0; i < len; i++) {
                String key = keys.next();
                map.put(key, headers.getString(key));
            }
            request.setHeaders(map);
        }

        if (path != null) {
            request.setFilePath(path);
            data.setPath(path);
        }

        if (fileName != null) {
            request.setFileName(fileName);
        }
        String id = manager.create(request);
        downloadsRequest.put(id, request);
        JSObject object = new JSObject();
        object.put("value", id);
        downloadsData.put(id, data);
        call.resolve(object);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void start(PluginCall call) {
        String id = call.getString("id");
        Manager manager = Manager.getInstance();
        DownloadData data = downloadsData.get(id);
        Request request = downloadsRequest.get(id);
        call.save();
        data.setCallback(call);
        if (request != null) {
            request.setListener(new Listener());
        }
        manager.start(id);
    }

    @PluginMethod()
    public void pause(PluginCall call) {
        String id = call.getString("id");
        Manager manager = Manager.getInstance();
        manager.pause(id);
    }

    @PluginMethod()
    public void resume(PluginCall call) {
        String id = call.getString("id");
        Manager manager = Manager.getInstance();
        manager.resume(id);
    }

    @PluginMethod()
    public void cancel(PluginCall call) {
        String id = call.getString("id");
        Manager manager = Manager.getInstance();
        manager.cancel(id);
    }

    @PluginMethod()
    public void getPath(PluginCall call) {
        String id = call.getString("id");
        DownloadData data = downloadsData.get(id);
        JSObject jsObject = new JSObject();
        if (data != null) {
            jsObject.put("value", data.getPath());
        }
        call.resolve(jsObject);
    }

    @PluginMethod()
    public void getStatus(PluginCall call) {
        String id = call.getString("id");
        DownloadData data = downloadsData.get(id);
        JSObject jsObject = new JSObject();
        if (data != null) {
            jsObject.put("value", data.getStatus());
        }
        call.resolve(jsObject);
    }
}
