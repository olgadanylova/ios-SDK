//
//  Channel.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2017 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "Channel.h"
#import "RTMessaging.h"
#import "PublishMessageInfoWrapper.h"

@interface Channel()
@property (strong, nonatomic, readwrite) NSString *channelName;
@property (strong, nonatomic) RTMessaging *rt;
@property (nonatomic, readwrite) BOOL isConnected;
@property (nonatomic, readwrite) NSMutableArray *waitingSubscriptions;
@property (strong, nonatomic) NSMapTable *wrappedSubscriptions;
@end

@implementation Channel

-(instancetype)initWithChannelName:(NSString *)channelName {
    if (self = [super init]) {
        self.channelName = channelName;
        self.rt = [[RTMessaging alloc] initWithChannelName:channelName];
        self.isConnected = NO;
        self.waitingSubscriptions = [NSMutableArray new];
        self.wrappedSubscriptions = [NSMapTable new];
    }
    return self;
}

-(void)connect {
    if (!self.isConnected) {
        __weak __typeof__(self) weakSelf = self;
        [self.rt connect:^(id result) {
            __typeof__(self) strongSelf = weakSelf;
            strongSelf.isConnected = YES;
            for (NSDictionary *waitingSubscription in self.waitingSubscriptions) {
                if ([[waitingSubscription valueForKey:@"event"] isEqualToString:PUB_SUB_CONNECT]) {
                    void(^onConnectResponse)(void) = [waitingSubscription valueForKey:@"onConnectResponse"];
                    onConnectResponse();
                }
            }
            [self subscribeForWaitingListeners];
        } onError: ^(Fault *fault) {
            for (NSDictionary *waitingSubscription in self.waitingSubscriptions) {
                if ([[waitingSubscription valueForKey:@"event"] isEqualToString:PUB_SUB_CONNECT]) {
                    void(^onError)(Fault *) = [waitingSubscription valueForKey:@"onError"];
                    onError(fault);
                }
            }
        }];
    }
}

-(void)disconnect {
    if (self.isConnected) {
        [self removeConnectListeners];
        [self removeMessageListeners];
        [self removeCommandListeners];
        [self removeUserStatusListeners];
        self.isConnected = NO;
    }
}

-(void)addConnectListener:(void(^)(void))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt addConnectListener:self.isConnected response:responseBlock error:errorBlock];
    }
    else {
        [self addWaitingListener:PUB_SUB_CONNECT selector:nil connectResponse:responseBlock response:nil error:errorBlock];
    }
}

-(void)removeConnectListeners:(void(^)(void))responseBlock {
    [self.rt removeConnectListeners:responseBlock];
}

-(void)removeConnectListeners {
    [self.rt removeConnectListeners:nil];
}

// ************************************************

-(void)addMessageListenerString:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    void(^onMessage)(PublishMessageInfo *) = [publishMessageInfoWrapper wrapResponseBlock:responseBlock error:errorBlock class:[NSString class]];
    [self.wrappedSubscriptions setObject:onMessage forKey:responseBlock];
    [self addMessageListener:onMessage error:errorBlock];
}

-(void)addMessageListenerString:(NSString *)selector response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    void(^onMessage)(PublishMessageInfo *) = [publishMessageInfoWrapper wrapResponseBlock:responseBlock error:errorBlock class:[NSString class]];
    [self.wrappedSubscriptions setObject:onMessage forKey:responseBlock];
    [self addMessageListener:selector response:onMessage error:errorBlock];
}

-(void)removeMessageListenersString:(NSString *)selector response:(void(^)(NSString *))responseBlock {
    [self removeMessageListeners:selector response:[self.wrappedSubscriptions objectForKey:responseBlock]];
}

-(void)removeMessageListenersStringWithCallback:(void(^)(NSString *))responseBlock {
    [self removeMessageListenersWithCallback:[self.wrappedSubscriptions objectForKey:responseBlock]];
}

// ************************************************

-(void)addMessageListenerDictionary:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock {
    void(^onMessage)(PublishMessageInfo *) = [publishMessageInfoWrapper wrapResponseBlock:responseBlock error:errorBlock class:[NSDictionary class]];
    [self.wrappedSubscriptions setObject:onMessage forKey:responseBlock];
    [self addMessageListener:onMessage error:errorBlock];}

-(void)addMessageListenerDictionary:(NSString *)selector response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock {
    void(^onMessage)(PublishMessageInfo *) = [publishMessageInfoWrapper wrapResponseBlock:responseBlock error:errorBlock class:[NSDictionary class]];
    [self.wrappedSubscriptions setObject:onMessage forKey:responseBlock];
    [self addMessageListener:selector response:onMessage error:errorBlock];
}

-(void)removeMessageListenersDictionary:(NSString *)selector response:(void(^)(NSDictionary *))responseBlock {
    [self removeMessageListeners:selector response:[self.wrappedSubscriptions objectForKey:responseBlock]];
}

-(void)removeMessageListenersDictionaryWithCallback:(void(^)(NSDictionary *))responseBlock {
    [self removeMessageListenersWithCallback:[self.wrappedSubscriptions objectForKey:responseBlock]];
}

// ************************************************

-(void)addMessageListenerCustomObject:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock class:(Class)classType {
    void(^onMessage)(PublishMessageInfo *) = [publishMessageInfoWrapper wrapResponseBlockToCustomObject:responseBlock error:errorBlock class:classType];
    [self.wrappedSubscriptions setObject:onMessage forKey:responseBlock];
    [self addMessageListener:onMessage error:errorBlock];
}

-(void)addMessageListenerCustomObject:(NSString *)selector response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock class:(Class)classType {
    void(^onMessage)(PublishMessageInfo *) = [publishMessageInfoWrapper wrapResponseBlockToCustomObject:responseBlock error:errorBlock class:classType];
    [self.wrappedSubscriptions setObject:onMessage forKey:responseBlock];
    [self addMessageListener:selector response:onMessage error:errorBlock];
}

-(void)removeMessageListenersCustomObject:(NSString *)selector response:(void(^)(id))responseBlock {
    [self removeMessageListeners:selector response:[self.wrappedSubscriptions objectForKey:responseBlock]];
}

-(void)removeMessageListenersCustomObjectWithCallback:(void(^)(id))responseBlock {
    [self removeMessageListenersWithCallback:[self.wrappedSubscriptions objectForKey:responseBlock]];
}

// ************************************************

-(void)addMessageListener:(void(^)(PublishMessageInfo *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self addMessageListener:nil response:responseBlock error:errorBlock];
}

-(void)addMessageListener:(NSString *)selector response:(void (^)(PublishMessageInfo *))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt addMessageListener:selector response:responseBlock error:errorBlock];
    }
    else {
        [self addWaitingListener:PUB_SUB_MESSAGES selector:selector connectResponse:nil response:responseBlock error:errorBlock];
    }
}

-(void)removeMessageListeners:(NSString *)selector response:(void (^)(PublishMessageInfo *))responseBlock {
    [self.rt removeMessageListeners:selector response:responseBlock];
}

-(void)removeMessageListenersWithCallback:(void(^)(PublishMessageInfo *))responseBlock {
    [self.rt removeMessageListeners:nil response:responseBlock];
}

-(void)removeMessageListenersWithSelector:(NSString *)selector {
    [self.rt removeMessageListeners:selector response:nil];
}

-(void)removeMessageListeners {
    [self.rt removeMessageListeners:nil response:nil];
}

-(void)addCommandListener:(void (^)(CommandObject *))responseBlock error:(void(^)(Fault *))errorBlock; {
    if (self.isConnected) {
        [self.rt addCommandListener:responseBlock error:errorBlock];
    }
    else {
        [self addWaitingListener:PUB_SUB_COMMANDS selector:nil connectResponse:nil response:responseBlock error:errorBlock];
    }
}

-(void)removeCommandListeners:(void (^)(CommandObject *))responseBlock {
    [self.rt removeCommandListeners:responseBlock];
}

-(void)removeCommandListeners {
    [self.rt removeCommandListeners:nil];
}

-(void)addUserStatusListener:(void (^)(UserStatusObject *))responseBlock error:(void (^)(Fault *))errorBlock {
    if (self.isConnected) {
        [self.rt addUserStatusListener:responseBlock error:errorBlock];
    }
    else {
        [self addWaitingListener:PUB_SUB_USERS selector:nil connectResponse:nil response:responseBlock error:errorBlock];
    }
}

-(void)removeUserStatusListeners:(void (^)(UserStatusObject *))responseBlock {
    [self.rt removeUserStatusListeners:responseBlock];
}

-(void)removeUserStatusListeners {
    [self.rt removeUserStatusListeners:nil];
}

-(void)removeAllListeners {
    [self removeConnectListeners];
    [self removeMessageListeners];
    [self removeCommandListeners];
    [self removeUserStatusListeners];
}

-(void)addWaitingListener:(NSString *)event selector:(NSString *)selector connectResponse:(void(^)(void))connectResponseBlock response:(void(^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    NSDictionary *waitingObject;
    if (connectResponseBlock) {
        if (selector) {
            waitingObject = @{@"event"              : event,
                              @"selector"           : selector,
                              @"onConnectResponse"  : connectResponseBlock,
                              @"onError"            : errorBlock};
        }
        else {
            waitingObject = @{@"event"              : event,
                              @"onConnectResponse"  : connectResponseBlock,
                              @"onError"            : errorBlock};
        }
    }
    else if (responseBlock) {
        if (selector) {
            waitingObject = @{@"event"      : event,
                              @"selector"   : selector,
                              @"onResponse" : responseBlock,
                              @"onError"    : errorBlock};
        }
        else {
            waitingObject = @{@"event"      : event,
                              @"onResponse" : responseBlock,
                              @"onError"    : errorBlock};
        }
    }
    [self.waitingSubscriptions addObject:waitingObject];
}

-(void)subscribeForWaitingListeners {
    for (NSDictionary *waitingSubscription in self.waitingSubscriptions) {
        if ([[waitingSubscription valueForKey:@"event"] isEqualToString:PUB_SUB_MESSAGES]) {
            if ([waitingSubscription valueForKey:@"selector"]) {
                [self addMessageListener:[waitingSubscription valueForKey:@"selector"] response:[waitingSubscription valueForKey:@"onResponse"] error:[waitingSubscription valueForKey:@"onError"]];
            }
            else {
                [self addMessageListener:[waitingSubscription valueForKey:@"onResponse"] error:[waitingSubscription valueForKey:@"onError"]];
            }
        }
        else if ([[waitingSubscription valueForKey:@"event"] isEqualToString:PUB_SUB_COMMANDS]) {
            [self addCommandListener:[waitingSubscription valueForKey:@"onResponse"] error:[waitingSubscription valueForKey:@"onError"]];
        }
        else if ([[waitingSubscription valueForKey:@"event"] isEqualToString:PUB_SUB_USERS]) {
            [self addUserStatusListener:[waitingSubscription valueForKey:@"onResponse"] error:[waitingSubscription valueForKey:@"onError"]];
        }
    }
    [self.waitingSubscriptions removeAllObjects];
}

@end
