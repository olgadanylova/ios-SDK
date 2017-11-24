//
//  RemoteSharedObject.m
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

#import "RemoteSharedObject.h"
#import "RTRemoteSharedObject.h"

@interface RemoteSharedObject()
@property (strong, nonatomic, readwrite) NSString *rsoName;
@property (strong, nonatomic) RTRemoteSharedObject *rt;
@property (nonatomic, readwrite) BOOL isConnected;
@end

@implementation RemoteSharedObject

-(instancetype)initWithRSOName:(NSString *)rsoName {
    if (self = [super init]) {
        self.rsoName = rsoName;
        self.rt = [[RTRemoteSharedObject alloc] initWithRSOName:rsoName];
        self.isConnected = NO;
    }
    return self;
}

-(void)connect {
    __weak __typeof__(self) weakSelf = self;
    [self.rt connect:^(id result) {
        __typeof__(self) strongSelf = weakSelf;
        strongSelf.isConnected = YES;
    }];
}

-(void)disconnect {
    [self removeErrorListener];
    [self removeConnectListener];
    [self removeChangesListener];
    [self removeClearListener];
    [self removeCommandListener];
    [self removeUserStatusListener];
    self.isConnected = NO;
}

-(void)addErrorListener:(void(^)(Fault *))errorBlock {
    [self.rt addErrorListener:errorBlock];
}

-(void)removeErrorListener:(void(^)(Fault *))errorBlock {
    [self.rt removeErrorListener:errorBlock];
}

-(void)removeErrorListener {
    [self.rt removeErrorListener:nil];
}

-(void)addConnectListener:(void(^)(void))onConnect {
    [self.rt addConnectListener:self.isConnected onConnect:onConnect];
}

-(void)removeConnectListener:(void(^)(void))onConnect {
    [self.rt removeConnectListener:onConnect];
}

-(void)removeConnectListener {
    [self.rt removeConnectListener:nil];
}

-(void)addChangesListener:(void(^)(RSOChangesObject *))onChanges {
    [self.rt addChangesListener:onChanges];
}

-(void)removeChangesListener:(void(^)(RSOChangesObject *))onChanges {
    [self.rt removeChangesListener:onChanges];
}

-(void)removeChangesListener {
    [self.rt removeChangesListener:nil];
}

-(void)addClearListener:(void(^)(RSOClearedObject *))onClear {
    [self.rt addClearListener:onClear];
}

-(void)removeClearListener:(void(^)(RSOClearedObject *))onClear {
    [self.rt removeClearListener:onClear];
}

-(void)removeClearListener {
    [self.rt removeClearListener:nil];
}

-(void)addCommandListener:(void(^)(CommandObject *))onCommand {
    [self.rt addCommandListener:onCommand];
}

-(void)removeCommandListener:(void(^)(CommandObject *))onCommand {
    [self.rt removeCommandListener:onCommand];
}

-(void)removeCommandListener {
    [self.rt removeCommandListener:nil];
}

-(void)addUserStatusListener:(void(^)(UserStatusObject *))onUserStatus {
    [self.rt addUserStatusListener:onUserStatus];
}

-(void)removeUserStatusListener:(void(^)(UserStatusObject *))onUserStatus {
    [self.rt removeUserStatusListener:onUserStatus];
}

-(void)removeUserStatusListener {
    [self.rt removeUserStatusListener:nil];
}

-(void)removeAllListeners {
    [self removeErrorListener];
    [self removeConnectListener];
    [self removeChangesListener];
    [self removeClearListener];
    [self removeCommandListener];
    [self removeUserStatusListener];
}

// commands

-(void)get:(void (^)(id))onSuccess onError:(void (^)(Fault *))onError {
    [self.rt get:nil onSuccess:onSuccess onError:onError];
}

-(void)get:(NSString *)key onSuccess:(void(^)(id))onSuccess onError:(void (^)(Fault *))onError {
    [self.rt get:key onSuccess:onSuccess onError:onError];
}

-(void)set:(NSString *)key data:(id)data onSuccess:(void(^)(id))onSuccess onError:(void (^)(Fault *))onError {
    [self.rt set:key data:data onSuccess:onSuccess onError:onError];
}

-(void)clear:(void(^)(id))onSuccess onError:(void (^)(Fault *))onError {
    [self.rt clear:onSuccess onError:onError];
}

-(void)sendCommand:(NSString *)commandName data:(id)data onSuccess:(void (^)(id))onSuccess onError:(void (^)(Fault *))onError {
    [self.rt sendCommand:commandName data:data onSuccess:onSuccess onError:onError];
}

@end
