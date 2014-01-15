LRNotificationObserver
======================
LRNotificationObserver is a smarter, simple and better way to use NSNotificationCenter with RAII.

## Installation

1. **Using CocoaPods**

  Add LRNotificationObserver to your Podfile:

  ```
  platform :ios, "6.0"
  pod 'LRNotificationObserver' 
  ```

  Run the following command:
  
  ```
  pod install
  ```

2. **Manually**

  Clone the project or add it as a submodule. Drag the whole LRNotificationObserver folder to your project.
  
## Usage

To listen for notifications as you do with NSNotificationCenter, you have to create a LRNotificationObserver instance. To do so, just use the following method:

```objective-c
+ (instancetype)observerForName:(NSString *)name
                          block:(LRNotificationObserverBlock)block;
```

When the notification with that name is fired, the block will be executed.

Imagine you want to listen for background notifications, instead of using NSNotificationCenter and having to implement dealloc just to unsubscribe, you can simply hold a LRNotificationObserver property in the object where you want to handle the notification (your view controller for instance) and let it be deallocated when the object dies. No more overriding dealloc just to unsubscribe from notifications. It is as simple as follows:

```objective-c
@property (nonatomic, strong) LRNotificationObserver *backgroundObserver;

self.backgroundObserver = [LRNotificationObserver observerForName:UIApplicationDidEnterBackgroundNotification
                                                            block:^(NSNotification *note) {
                                                                // Do appropriate background task
                                                            }];
```

The most interesting method in LRNotificationObserver is *stopObserving* in case you want to unsubscribe in other places different from dealloc (*viewWillDisappear* from instance).

Most times you just want to unsubscribe in dealloc. Having to hold a LRNotificationObserver property just to maintain this object alive can be a little bummer sometimes. It's cleaner than implementing dealloc to do so for sure, but it's even cleaner to not do this... There's a way to do that, just us the following method:

```objective-c
+ (void)observeName:(NSString *)name
              owner:(id)owner
              block:(LRNotificationObserverBlock)block;
```

You must provide an owner, which is in charge of retaining the LRNotificationObserver object which is created under the hood. Don't worry, that owner won't be retained whatsover. The observer will be attached to the owner in runtime and release it when the latter is deallocated. 

Imagine you want to listen for memory warning notifications. Just use the following code.

```objective-c
[LRNotificationObserver observeName:UIApplicationDidReceiveMemoryWarningNotification
                              owner:self
                              block:^(NSNotification *note) {
                                  // Purge unnecessary cache
                              }];
```

That's it, no deallocs, no holding properties. Just that code.

There are several ways of getting the notification callbacks. You can use blocks or target-action pattern and specify the queue (NSOperationQueue and dispatch queue) in which you want to receive that callback. You can also specify the object from which you want to receive the notificaitons.

Imagine you want to update the UI when receving a notification in a specific method. The following code does so:

```objective-c
[LRNotificationObserver observeName:@"someNotificationThatShouldUpdateUI"
                             object:anObject
                              owner:anOwner
                     dispatch_queue:dispatch_get_main_queue()
                             target:viewController
                           selector:@selector(methodToBeExecutedOnMainThread)];
```

## Requirements

LRNotificationObserver requires both iOS 6.0 and ARC.

You can still use LRNotificationObserver in your non-arc project. Just set -fobjc-arc compiler flag in every source file.

## Contact

LRNotificationObserver was created by Luis Recuenco: [@luisrecuenco](https://twitter.com/luisrecuenco).

## Contributing

If you want to contribute to the project just follow this steps:

1. Fork the repository.
2. Clone your fork to your local machine.
3. Create your feature branch with the appropriate tests.
4. Commit your changes, run the tests, push to your fork and submit a pull request.

## Tests

In order to run the test suit, you should have the latest version of xctool. This can be done as follows:

```ruby
rake test:prepare_for_xctool
```

After that, running the tests is as simple as typing

```ruby
rake
```

## License

LRNotificationObserver is available under the MIT license. See the [LICENSE file](https://github.com/luisrecuenco/LRNotificationObserver/blob/master/LICENSE) for more info.




