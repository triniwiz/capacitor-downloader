import {
  IDownloader,
  IStatusCode,
  DownloadOptions,
  DownloadEventData,
  Options
} from './definitions';
import { Plugins } from '@capacitor/core';
const { DownloaderPlugin } = Plugins;
export class Downloader implements IDownloader {
  initialize() {
    DownloaderPlugin.initialize();
  }
  init() {
    this.init();
  }
  getStatus(options: Options): Promise<IStatusCode> {
    return DownloaderPlugin.getStatus(options);
  }
  createDownload(options: DownloadOptions): Promise<any> {
    return DownloaderPlugin.createDownload(options);
  }
  start(options: Options, progress?: Function): Promise<DownloadEventData> {
    return new Promise(async (resolve, reject) => {
      DownloaderPlugin.start(options, (data: any, error: string) => {
        if (!error) {
          if (data['status'] != null) {
            resolve(data);
          } else {
            progress(data);
          }
        } else {
          reject({
            status: 'error',
            message: error
          });
        }
      });
    });
  }
  pause(options: Options): Promise<any> {
    return DownloaderPlugin.pause(options);
  }
  resume(options: Options): Promise<any> {
    return DownloaderPlugin.resume(options);
  }
  getPath(options: Options): Promise<string> {
    return DownloaderPlugin.getPath(options);
  }
}
