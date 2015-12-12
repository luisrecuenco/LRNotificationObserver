Pod::Spec.new do |s|
  s.name     = 'LRNotificationObserver'
  s.version  = '0.1.2'
  s.license  = 'MIT'
  s.summary  = 'A smarter, simple and better way to use NSNotificationCenter with RAII.'
  s.homepage = 'https://github.com/luisrecuenco/LRNotificationObserver'
  s.author   = { "Luis Recuenco" => "luisrecuenco@gmail.com" }
  s.source   = { :git => 'https://github.com/luisrecuenco/LRNotificationObserver.git', :tag => '0.1.2' }
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.tvos.deployment_target = '9.0'
  s.source_files = 'LRNotificationObserver'
  s.requires_arc = true
end

