namespace :test do
    desc "Install xctool if necessary"
    task :prepare do
        system("brew install xctool")
    end

    desc "Run the LRNotificationObserver tests with xctool"
    task :xctool => :prepare do
        $success = system("cd Example && pod install && xctool test -workspace LRNotificationObserverExample.xcworkspace -scheme LRNotificationObserverExampleTests -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO")
    end

    desc "Run the LRNotificationObserver tests with xcodebuild"
    task :xcodebuild do
        $success = system('cd Example && pod install && xcodebuild test -workspace LRNotificationObserverExample.xcworkspace -scheme LRNotificationObserverExampleTests -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO')
    end
end

desc "Run the LRNotificationObserver tests"
task :test => 'test:xcodebuild' do
    if $success
        puts "\033[0;32m** All tests executed successfully **"
    else
        puts "\033[0;31m** iOS unit tests failed **"
    end
end

task :default => :test
