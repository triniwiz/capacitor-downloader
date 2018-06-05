import { Component, ViewChild, ElementRef, NgZone } from '@angular/core';
import { NavController } from 'ionic-angular';
import { Downloader } from 'capacitor-downloader';
import {DomSanitizer} from '@angular/platform-browser';
@Component({
  selector: 'page-home',
  templateUrl: 'home.html'
})
export class HomePage {
  fileSpeed: number = 0;
  imageSpeed: number = 0;
  fileProgress: number = 0;
  imageProgress: number = 0;
  downloadManager: Downloader;
  imageDownloaderId: string;
  fileDownloaderId: string;
  image: any;
  @ViewChild('fProgress') fProgress: ElementRef;
  @ViewChild('iProgress') iProgress: ElementRef;
  constructor(public navCtrl: NavController, private zone: NgZone, private sanitizer:DomSanitizer) {}

  async downloadImage(event) {
    const data = await this.downloadManager.start(
      {
        id: this.imageDownloaderId
      },
      progress => {
        const elem = event;
        this.zone.run(() => {
          this.imageProgress = progress.value;
          this.imageSpeed = progress.speed;
        });
        elem.style.width = progress.value + '%';
        elem.innerHTML = progress.value * 1 + '%';
      }
    );
    this.zone.run(() => {
    this.image = this.sanitizer.bypassSecurityTrustUrl(data['path']);
    });
  }
  async downloadFile(event) {
    await this.downloadManager.start(
      {
        id: this.fileDownloaderId
      },
      progress => {
        this.zone.run(() => {
          this.fileProgress = progress.value;
          this.fileSpeed = progress.speed;
        });
        const elem = event;
        elem.style.width = progress.value + '%';
        elem.innerHTML = progress.value * 1 + '%';
      }
    );
  }
  resumeFile() {
    this.downloadManager.resume({ id: this.fileDownloaderId });
  }
  pauseFile() {
    this.downloadManager.pause({ id: this.fileDownloaderId });
  }
  async generateDownloads() {
    this.downloadManager = new Downloader();
    this.fileProgress = 0;
    this.imageProgress = 0;
    const imageDownloaderIdObj = await this.downloadManager.createDownload({
      url:
        'https://images.wallpaperscraft.com/image/abraao_segundo_monster_green_hair_chains_irons_discharge_94534_3840x2400.jpg'
    });
    this.imageDownloaderId = imageDownloaderIdObj['value'];
    console.log(`Image Id :${this.imageDownloaderId} `);

    const fileDownloaderIdObj = await this.downloadManager.createDownload({
      url: 'http://ipv4.download.thinkbroadband.com/50MB.zip'
    });
    this.fileDownloaderId = fileDownloaderIdObj['value'];
    console.log(`File Id :${this.fileDownloaderId} `);
  }
  async generateAndStart() {
    await this.generateDownloads();
    await this.downloadImage(this.iProgress.nativeElement);
    await this.downloadFile(this.fProgress.nativeElement);
  }
}
