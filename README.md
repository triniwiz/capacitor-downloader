# Capacitor Downloader

[![npm](https://img.shields.io/npm/v/capacitor-downloader.svg)](https://www.npmjs.com/package/capacitor-downloader)
[![npm](https://img.shields.io/npm/dt/capacitor-downloader.svg?label=npm%20downloads)](https://www.npmjs.com/package/capacitor-downloader)
[![Build Status](https://travis-ci.org/triniwiz/capacitor-downloader.svg?branch=master)](https://travis-ci.org/triniwiz/capacitor-downloader)

## Installation

* `npm i capacitor-downloader`

### Android

Add `import co.fitcom.capacitor.Downloader.DownloaderPlugin;` and `add(DownloaderPlugin.class);` in the app's `MainActivity.java` like this:

```
import co.fitcom.capacitor.Downloader.DownloaderPlugin;

public class MainActivity extends BridgeActivity {
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    // Initializes the Bridge
    this.init(savedInstanceState, new ArrayList<Class<? extends Plugin>>() {{
      // Additional plugins you've installed go here
      // Ex: add(TotallyAwesomePlugin.class);
      add(DownloaderPlugin.class);
    }});
  }
}
```

## Usage

```ts
import { Downloader, DownloadEventData, ProgressEventData } from 'capacitor-downloader';
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
