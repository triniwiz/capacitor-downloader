#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>
// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(DownloaderPlugin, "DownloaderPlugin",
           CAP_PLUGIN_METHOD(initialize, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(createDownload, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(start, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(pause, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(resume, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(cancel, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getPath, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getStatus, CAPPluginReturnPromise);
           )
