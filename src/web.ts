import { WebPlugin } from '@capacitor/core';

export class DownloaderWebPlugin extends WebPlugin {
  constructor() {
    super({
      name: 'Downloader',
      platforms: ['web']
    });
  }
}

const MyPlugin = new DownloaderWebPlugin();

export { MyPlugin };
