# Capacitor Downloader

[![npm](https://img.shields.io/npm/v/capacitor-downloader.svg)](https://www.npmjs.com/package/capacitor-downloader)
[![npm](https://img.shields.io/npm/dt/capacitor-downloader.svg?label=npm%20downloads)](https://www.npmjs.com/package/capacitor-downloader)
[![Build Status](https://travis-ci.org/triniwiz/capacitor-downloader.svg?branch=master)](https://travis-ci.org/triniwiz/capacitor-downloader)

## Installation

* `npm i capacitor-downloader`

## Usage

```ts
import { Downloader } from 'capacitor-downloader';
const downloader = new Downloader();
const data = await downloader.createDownload({
  url:
    'https://wallpaperscraft.com/image/hulk_wolverine_x_men_marvel_comics_art_99032_3840x2400.jpg'
});
const imageDownloaderId = data.value;
downloader
  .start({id:imageDownloaderId}, (progressData: ProgressEventData) => {
    console.log(`Progress : ${progressData.value}%`);
    console.log(`Current Size : ${progressData.currentSize}%`);
    console.log(`Total Size : ${progressData.totalSize}%`);
    console.log(`Download Speed in bytes : ${progressData.speed}%`);
  })
  .then((completed: DownloadEventData) => {
    console.log(`Image : ${completed.path}`);
  })
  .catch(error => {
    console.log(error.message);
  });
```

## Api

| Method                                   | Default | Type                         | Description                                           |
| ---------------------------------------- | ------- | ---------------------------- | ----------------------------------------------------- |
| createDownload(options: DownloadOptions) |         | `Promise<Options>`                     | Creates a download task it returns the id of the task |
| getStatus(options:Options)                    |         | `Promise<StatusCode>`                 | Gets the status of a download task.                   |
| start(options:Options, progress?: Function)   |         | `Promise<DownloadEventData>` | Starts a download task.                               |  |
| resume(options:Options)                       |         | `Promise<void>`                       | Resumes a download task.                              |
| cancel(options:Options)                       |         | `Promise<void>`                       | Cancels a download task.                              |
| pause(options:Options)                        |         | `Promise<void>`                       | Pauses a download task.                               |
| getPath(options:Options)                      |         | `Promise<void>`                       | Return the path of a download task.                   |

## Example Image

| IOS                                     | Android                                     |
| --------------------------------------- | ------------------------------------------- |
| Coming Soon | Coming Soon |

# TODO

* [ ] Local Notifications
