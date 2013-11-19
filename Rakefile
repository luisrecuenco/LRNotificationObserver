desc 'Run the tests'
task :test do
    exec('cd Example && xcodebuild test -workspace LRNotificationObserverExample.xcworkspace -scheme LRNotificationObserverExampleTests -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO')
end

task :default => :test
