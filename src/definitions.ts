declare global {
  interface PluginRegistry {
    DownloaderPlugin?: IDownloader;
  }
}

export interface IDownloader {
  initialize(): void;
  createDownload(options: DownloadOptions): Promise<any>;
  start(options: Options, progress?: Function): Promise<any>;
  pause(options: Options): Promise<any>;
  resume(options: Options): Promise<any>;
  cancel(options:Options): Promise<any>;
  getPath(options: Options): Promise<string>;
  getStatus(options: Options): Promise<IStatusCode>;
}

export interface  TimeOutOptions {
    timeout: number;
}

export interface Options {
  id: string;
}

export interface StartCallback {
  success: DownloadEventData;
  progress: ProgressEventData;
  error: DownloadEventError;
}

export interface DownloadEventError {
  status: string;
  message: string;
}

export interface DownloadEventData {
  status: string;
  path: string;
  message?: string;
}
export interface ProgressEventData {
  value: number;
  currentSize: number;
  totalSize: number;
  speed: number;
}

export interface IStatusCode {
  value: StatusCode;
}
export enum StatusCode {
  PENDING = 'pending',
  PAUSED = 'paused',
  DOWNLOADING = 'downloading',
  COMPLETED = 'completed',
  ERROR = 'error'
}

export interface DownloadOptions {
  url: string;
  query?: Object | string;
  headers?: Object;
  path?: string;
  fileName?: string;
}
