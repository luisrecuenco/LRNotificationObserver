// LRNotificationObserverTests.m
//
// Copyright (c) 2013 Luis Recuenco
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "Kiwi.h"
#import "LRNotificationObserver.h"

static SEL sNoArgumentsSelector;
static SEL sOneArgumentsSelector;

static NSNotification *sNotification;

static NSOperationQueue *sCallbackOperationQueue;

static const void *sCallbackDispatchQueueTag = &sCallbackDispatchQueueTag;
static const void *sCallbackDispatchQueueContext;


@interface LRNotificationTarget : NSObject

@end

@implementation LRNotificationTarget

+ (void)initialize
{
    if (self == [LRNotificationTarget class])
    {
        sNoArgumentsSelector = @selector(notificationFired);
        sOneArgumentsSelector = @selector(notificationFired:);
    }
}

- (void)notificationFired
{
    sCallbackOperationQueue = [NSOperationQueue currentQueue];
    sCallbackDispatchQueueContext = dispatch_get_specific(sCallbackDispatchQueueTag);
}

- (void)notificationFired:(NSNotification *)aNotification
{
    sNotification = aNotification;
    sCallbackOperationQueue = [NSOperationQueue currentQueue];
    sCallbackDispatchQueueContext = dispatch_get_specific(sCallbackDispatchQueueTag);
}

@end

SPEC_BEGIN(Test)

describe(@"LRNotificationObserverTests", ^{
    
    __block LRNotificationObserver *sut = nil;
    __block NSNotificationCenter *notificationCenter = nil;
    __block LRNotificationTarget *target = nil;
    
    context(@"With not valid notification center", ^{
        
        it(@"block based notification observer should raise exception", ^{
            
#if !NS_BLOCK_ASSERTIONS
            [[theBlock(^{
                sut = [[LRNotificationObserver alloc] initWithNotificationCenter:nil];
            }) should] raise];
#else
            [[theBlock(^{
                sut = [[LRNotificationObserver alloc] initWithNotificationCenter:nil];
            }) shouldNot] raise];
#endif
        });
    });
    
    context(@"With valid notification center", ^{
        
        beforeEach(^{
            notificationCenter = [NSNotificationCenter defaultCenter];
            sut = [[LRNotificationObserver alloc]
                   initWithNotificationCenter:notificationCenter];
        });
        
        afterEach(^{
            sut = nil;
            notificationCenter = nil;
        });
        
        it(@"notificaton center created correctly", ^{
            [[sut shouldNot] beNil];
        });
        
        context(@"Block based", ^{
            
            it(@"sut block called sync", ^{
                
                NSString *notificationName = @"aNotificationName";
                
                __block BOOL completionBlockCalled = NO;
                
                [sut configureForName:notificationName
                                block:^(NSNotification *note) {
                                    completionBlockCalled = YES;
                                }];
                
                [notificationCenter postNotificationName:notificationName object:nil];
                
                [[theValue(completionBlockCalled) should] beYes];
            });
            
            it(@"sut with operation queue block called async", ^{
                
                NSString *notificationName = @"aNotificationName";
                NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
                __block BOOL completionBlockCalled = NO;
                
                [sut configureForName:notificationName
                       operationQueue:opQueue
                                block:^(NSNotification *note) {
                                    completionBlockCalled = YES;
                                }];
                
                [notificationCenter postNotificationName:notificationName object:nil];
                
                [[theValue(completionBlockCalled) should] beNo];
                [[expectFutureValue(theValue(completionBlockCalled)) shouldEventually] beYes];
            });
            
            it(@"sut with dispatch queue block called async", ^{
                
                NSString *notificationName = @"aNotificationName";
                dispatch_queue_t serialQueue = dispatch_queue_create("com.LRNotificationObserver.LRNotificationObserverTestsQueue", DISPATCH_QUEUE_SERIAL);
                __block BOOL completionBlockCalled = NO;
                
                [sut configureForName:notificationName
                        dispatchQueue:serialQueue
                                block:^(NSNotification *note) {
                                    completionBlockCalled = YES;
                                }];
                
                [notificationCenter postNotificationName:notificationName object:nil];
                
                [[theValue(completionBlockCalled) should] beNo];
                [[expectFutureValue(theValue(completionBlockCalled)) shouldEventually] beYes];
            });
            
            it(@"sut with wrong notification name block not called", ^{
                
                NSString *notificationName = @"aNotificationName";
                NSString *anotherNotificationName = @"anotherNotificationName";
                
                __block BOOL completionBlockCalled = NO;
                
                [sut configureForName:notificationName
                                block:^(NSNotification *note) {
                                    completionBlockCalled = YES;
                                }];
                
                [notificationCenter postNotificationName:anotherNotificationName object:nil];
                
                [[theValue(completionBlockCalled) should] beNo];
            });
            
            it(@"sut with nil block should raise exception", ^{
                
                NSString *notificationName = @"aNotificationName";
#if !NS_BLOCK_ASSERTIONS
                [[theBlock(^{
                    [sut configureForName:notificationName
                                    block:nil];
                }) should] raise];
#else
                [[theBlock(^{
                    [sut configureForName:notificationName
                                    block:nil];
                }) shouldNot] raise];
#endif
            });
            
            it(@"sut block parameter should be of class NSNotification", ^{
                
                NSString *notificationName = @"aNotificationName";
                
                __block NSNotification *notification = nil;
                
                [sut configureForName:notificationName
                                block:^(NSNotification *note) {
                                    notification = note;
                                }];
                
                [notificationCenter postNotificationName:notificationName object:nil];
                
                [[notification should] beKindOfClass:[NSNotification class]];
            });
            
            it(@"sut configure twice should call last configured block", ^{
                
                NSString *notificationName = @"aNotificationName";
                
                __block BOOL firstCompletionBlockCalled = NO;
                __block BOOL secondCompletionBlockCalled = NO;
                
                [sut configureForName:notificationName block:^(NSNotification *note) {
                    firstCompletionBlockCalled = YES;
                }];
                
                [sut configureForName:notificationName block:^(NSNotification *note) {
                    secondCompletionBlockCalled = YES;
                }];
                
                [notificationCenter postNotificationName:notificationName object:nil];
                
                [[theValue(firstCompletionBlockCalled) should] beNo];
                [[theValue(secondCompletionBlockCalled) should] beYes];
            });
            
            it(@"sut block not called after stopObserving", ^{
                
                NSString *notificationName = @"aNotificationName";
                
                __block BOOL completionBlockCalled = NO;
                
                [sut configureForName:notificationName
                                block:^(NSNotification *note) {
                                    completionBlockCalled = YES;
                                }];
                
                [sut stopObserving];
                
                [notificationCenter postNotificationName:notificationName object:nil];
                
                [[theValue(completionBlockCalled) should] beNo];
            });
            
            it(@"sut block should be called in correct operation queue", ^{
                
                NSString *notificationName = @"aNotificationName";
                
                __block NSOperationQueue *callbackQueue = NULL;
                
                NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
                
                [sut configureForName:notificationName
                       operationQueue:opQueue
                                block:^(NSNotification *note) {
                                    callbackQueue = [NSOperationQueue currentQueue];
                                }];
                
                [notificationCenter postNotificationName:notificationName object:nil];
                
                [[expectFutureValue(callbackQueue) shouldEventually] beIdenticalTo:opQueue];
            });
            
            it(@"sut block should be called in correct dispatch queue", ^{
                
                NSString *notificationName = @"aNotificationName";
                
                dispatch_queue_t serialQueue = dispatch_queue_create("com.LRNotificationObserver.LRNotificationObserverTestsQueue", DISPATCH_QUEUE_SERIAL);
                
                void *queueTag = &queueTag;
                void *queueContext = &queueContext;
                
                __block void *callbackQueueContext = NULL;
                
                dispatch_queue_set_specific(serialQueue, queueTag, queueContext, NULL);
                
                [sut configureForName:notificationName
                        dispatchQueue:serialQueue
                                block:^(NSNotification *note) {
                                    callbackQueueContext = dispatch_get_specific(queueTag);
                                }];
                
                [notificationCenter postNotificationName:notificationName object:nil];
                
                [[expectFutureValue(theValue(queueContext == callbackQueueContext)) shouldEventually] beYes];
            });
        });
        
        context(@"Target seletor based", ^{
            
            beforeEach(^{
                target = [[LRNotificationTarget alloc] init];
                sNotification = nil;
                sCallbackOperationQueue = nil;
                sCallbackDispatchQueueContext = NULL;
            });
            
            it(@"sut called sync", ^{
                
                NSString *notificationName = @"aNotificationName";
                
                [sut configureForName:notificationName
                               target:target
                               action:sNoArgumentsSelector];
                
                [[target should] receive:sNoArgumentsSelector];
                
                [notificationCenter postNotificationName:notificationName object:nil];
            });
            
            it(@"sut with operation queue called async", ^{
                
                NSString *notificationName = @"aNotificationName";
                NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
                
                [sut configureForName:notificationName
                       operationQueue:opQueue
                               target:target
                               action:sNoArgumentsSelector];
                
                [[target shouldNot] receive:sNoArgumentsSelector];
                [[target shouldEventually] receive:sNoArgumentsSelector];
                
                [notificationCenter postNotificationName:notificationName object:nil];
            });
            
            it(@"sut with dispatch queue called async", ^{
                
                NSString *notificationName = @"aNotificationName";
                dispatch_queue_t serialQueue = dispatch_queue_create("com.LRNotificationObserver.LRNotificationObserverTestsQueue", DISPATCH_QUEUE_SERIAL);
                
                [sut configureForName:notificationName
                        dispatchQueue:serialQueue
                               target:target
                               action:sNoArgumentsSelector];
                
                [[target shouldNot] receive:sNoArgumentsSelector];
                [[target shouldEventually] receive:sNoArgumentsSelector];
                
                [notificationCenter postNotificationName:notificationName object:nil];
            });
            
            it(@"sut with wrong notification name selector not called", ^{
                
                NSString *notificationName = @"aNotificationName";
                NSString *anotherNotificationName = @"anotherNotificationName";
                
                [sut configureForName:notificationName target:target action:sOneArgumentsSelector];
                
                [notificationCenter postNotificationName:anotherNotificationName object:nil];
                
                [[target shouldNot] receive:sOneArgumentsSelector];
            });
            
            it(@"sut with unknown selector should raise exception", ^{
                
                NSString *notificationName = @"aNotificationName";
                
                SEL unknownSelector = NSSelectorFromString(@"unknownSelector");
                
#if !NS_BLOCK_ASSERTIONS
                [[theBlock(^{
                    [sut configureForName:notificationName
                                   target:target
                                   action:unknownSelector];
                }) should] raise];
#else
                [[theBlock(^{
                    [sut configureForName:notificationName
                                   target:target
                                   action:unknownSelector];
                }) shouldNot] raise];
#endif
            });
            
            it(@"sut with nil target should raise exception", ^{
                
                NSString *notificationName = @"aNotificationName";
                
#if !NS_BLOCK_ASSERTIONS
                [[theBlock(^{
                    [sut configureForName:notificationName
                                   target:nil
                                   action:sOneArgumentsSelector];
                }) should] raise];
#else
                [[theBlock(^{
                    [sut configureForName:notificationName
                                   target:nil
                                   action:sOneArgumentsSelector];
                }) shouldNot] raise];
#endif
            });
            
            it(@"sut selector parameter should be of class NSNotification", ^{
                
                NSString *notificationName = @"aNotificationName";
                
                [sut configureForName:notificationName target:target action:sOneArgumentsSelector];
                
                [notificationCenter postNotificationName:notificationName object:nil];
                
                [[sNotification should] beKindOfClass:[NSNotification class]];
            });
            
            
            it(@"sut configure twice should call last configured selector", ^{
                
                NSString *notificationName = @"aNotificationName";
                
                [sut configureForName:notificationName target:target action:sNoArgumentsSelector];
                [sut configureForName:notificationName target:target action:sOneArgumentsSelector];
                
                [[target shouldNot] receive:sNoArgumentsSelector];
                [[target should] receive:sOneArgumentsSelector];
                
                [notificationCenter postNotificationName:notificationName object:nil];
            });
            
            it(@"sut selector not called after stopObserving", ^{
                
                NSString *notificationName = @"aNotificationName";
                
                [sut configureForName:notificationName
                               target:target
                               action:sNoArgumentsSelector];
                
                [sut stopObserving];
                
                [[target shouldNot] receive:sNoArgumentsSelector];
                
                [notificationCenter postNotificationName:notificationName object:nil];
            });
            
            it(@"sut selector should be called in correct operation queue", ^{
                
                NSString *notificationName = @"aNotificationName";
                
                NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
                
                [sut configureForName:notificationName
                       operationQueue:opQueue
                               target:target
                               action:sNoArgumentsSelector];
                
                [notificationCenter postNotificationName:notificationName object:nil];
                
                [[expectFutureValue(sCallbackOperationQueue) shouldEventually] beIdenticalTo:opQueue];
            });
            
            it(@"sut selector should be called in correct dispatch queue", ^{
                
                NSString *notificationName = @"aNotificationName";
                
                dispatch_queue_t serialQueue = dispatch_queue_create("com.LRNotificationObserver.LRNotificationObserverTestsQueue", DISPATCH_QUEUE_SERIAL);
                
                void *queueContext = &queueContext;
                
                dispatch_queue_set_specific(serialQueue, sCallbackDispatchQueueTag, queueContext, NULL);
                
                [sut configureForName:notificationName
                        dispatchQueue:serialQueue
                               target:target
                               action:sNoArgumentsSelector];
                
                [notificationCenter postNotificationName:notificationName object:nil];
                
                [[expectFutureValue(theValue(sCallbackDispatchQueueContext == queueContext)) shouldEventually] beYes];
            });
        });
    });
});

SPEC_END
