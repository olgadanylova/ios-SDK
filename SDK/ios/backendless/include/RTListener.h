//
//  RTListener.h
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

#import <Foundation/Foundation.h>

#define ERROR_TYPE @"ERROR"
#define OBJECTS_CHANGES_TYPE @"OBJECTS_CHANGES"
#define PUB_SUB_CONNECT_TYPE @"PUB_SUB_CONNECT"
#define PUB_SUB_MESSAGES_TYPE @"PUB_SUB_MESSAGES"
#define PUB_SUB_COMMAND_TYPE @"PUB_SUB_COMMAND"
#define PUB_SUB_COMMANDS_TYPE @"PUB_SUB_COMMANDS"
#define PUB_SUB_USERS_TYPE @"PUB_SUB_USERS"

@interface RTListener : NSObject
@end
