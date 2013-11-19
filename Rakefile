desc 'Run the tests'
task :test do
    exec('cd Example && pod install && xcodebuild test -workspace LRNotificationObserverExample.xcworkspace -scheme LRNotificationObserverExampleTests -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO')
end

task :default => :test
