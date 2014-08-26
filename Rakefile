namespace :test do
    desc "Install xctool latest version necessary to run the tests"
    task :prepare_for_xctool do
        system("brew update && brew uninstall xctool && brew install xctool --HEAD")
    end

    desc "Install cocoa pods dependencies"
    task :cocoa_pods do
        system("cd Example && pod install")
    end

    desc "Run the LRNotificationObserver tests with xctool"
    task :xctool => :cocoa_pods do
        $success = system("cd Example && xctool test -workspace LRNotificationObserverExample.xcworkspace -scheme LRNotificationObserverExampleTests -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO")
    end

    desc "Run the LRNotificationObserver tests with xcodebuild"
    task :xcodebuild => :cocoa_pods do
        $success = system('cd Example && xcodebuild test -workspace LRNotificationObserverExample.xcworkspace -scheme LRNotificationObserverExampleTests -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO')
    end
end

desc "Run the LRNotificationObserver tests"
task :test => 'test:xcodebuild' do
    if $success
        puts "\033[0;32m** iOS unit tests passed successfully **"
    else
        puts "\033[0;31m** iOS unit tests failed **"
    end
end

task :default => :test
