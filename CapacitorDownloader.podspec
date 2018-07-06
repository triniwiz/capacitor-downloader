
  Pod::Spec.new do |s|
    s.name = 'CapacitorDownloader'
    s.version = '1.0.0'
    s.summary = 'Downloader'
    s.license = 'MIT'
    s.homepage = 'https://github.com/triniwiz/capacitor-downloader'
    s.author = 'Osei Fortune'
    s.source = { :git => '', :tag => s.version.to_s }
    s.source_files = 'ios/Plugin/Plugin/*.{swift,h,m,c,cc,mm,cpp}' ,'ios/Plugin/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '10.0'
    s.dependency 'Capacitor'
    s.dependency 'Alamofire', '~> 4.7'
  end
