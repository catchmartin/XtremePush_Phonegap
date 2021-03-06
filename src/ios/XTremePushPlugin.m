//
//  XTremePushPlugin.m
//  push
//
//  Created by Dima Maleev on 6/7/14.
//
//

#import "XTremePushPlugin.h"

@implementation XTremePushPlugin

@synthesize asyncCallbackId;
@synthesize callback;
@synthesize notificationMessage;
@synthesize showAlerts;
@synthesize isInline;


- (void) register:(CDVInvokedUrlCommand *)command
{
    self.asyncCallbackId = command.callbackId;
    NSMutableDictionary* options = [command.arguments objectAtIndex:0];
    
    UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeNone;
    
    id badgeArg = [options objectForKey:@"badge"];
    id soundArg = [options objectForKey:@"sound"];
    id alertArg = [options objectForKey:@"alert"];
    
    self.showAlerts = [[options objectForKey:@"showAlerts"] boolValue];
    
    if ([badgeArg isKindOfClass:[NSString class]])
    {
        if ([badgeArg isEqualToString:@"true"])
            notificationTypes |= UIRemoteNotificationTypeBadge;
    }
    else if ([badgeArg boolValue])
        notificationTypes |= UIRemoteNotificationTypeBadge;
    
    if ([soundArg isKindOfClass:[NSString class]])
    {
        if ([soundArg isEqualToString:@"true"])
            notificationTypes |= UIRemoteNotificationTypeSound;
    }
    else if ([soundArg boolValue])
        notificationTypes |= UIRemoteNotificationTypeSound;
    
    if ([alertArg isKindOfClass:[NSString class]])
    {
        if ([alertArg isEqualToString:@"true"])
            notificationTypes |= UIRemoteNotificationTypeAlert;
    }
    else if ([alertArg boolValue])
        notificationTypes |= UIRemoteNotificationTypeAlert;
    
    if (notificationTypes == UIRemoteNotificationTypeNone)
        NSLog(@"PushPlugin.register: Push notification type is set to none");
    
    isInline = NO;
    
    self.callback = [options objectForKey:@"callbackFunction"];
    
    [XPush registerForRemoteNotificationTypes:notificationTypes];
}

- (void) unregister:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Unregister from remote notifications called");

    NSString *callbackId = command.callbackId;
    [XPush unregisterForRemoteNotifications];
    [self successWithMessage:@"" withCallbackId:callbackId];
}

- (void) isSandboxModeOn:(CDVInvokedUrlCommand *)command
{
    NSLog(@"isSandboxModedeOn called");
    
    NSString *callbackId = command.callbackId;
    BOOL isSandboxModeOn = [XPush isSandboxModeOn];
    
    NSString *result = (isSandboxModeOn) ? @"true" : @"false";
    
    [self successWithMessage:result withCallbackId:callbackId];
}

- (void) version:(CDVInvokedUrlCommand *)command
{
    NSLog(@"version called");
    
    NSString * callbackId = command.callbackId;
    
    [self successWithMessage:[XPush version] withCallbackId:callbackId];
}

- (void) deviceInfo:(CDVInvokedUrlCommand *)command
{
    NSLog(@"deviceInfo called");
    
    NSString *callbackId = command.callbackId;
    
    NSDictionary *deviceInfo = [XPush deviceInfo];
    
    NSMutableString *jsonStr = [NSMutableString stringWithString:@"{"];
    
    [self parseDictionary:deviceInfo intoJSON:jsonStr];
    
    [self successWithMessage:jsonStr withCallbackId:callbackId];
}

- (void) shouldWipeBadgeNumber:(CDVInvokedUrlCommand *)command
{
    NSLog(@"shouldWipeBadgeNumber called");
    
    NSString *callbackId = command.callbackId;
    
    BOOL shouldWipeBadgeNumber = [XPush shouldWipeBadgeNumber];
    
    NSString *result = (shouldWipeBadgeNumber) ? @"true" : @"false";

    [self successWithMessage:result withCallbackId:callbackId];
}

- (void) setShouldWipeBadgeNumber:(CDVInvokedUrlCommand *)command
{
    NSLog(@"setShouldWipeBadgeNumber called");
    
    NSString *callbackId = command.callbackId;
    BOOL value = [[command.arguments objectAtIndex:0] boolValue];
    [XPush setShouldWipeBadgeNumber:value];
    [self successWithMessage:@"" withCallbackId:callbackId];
}

- (void) setLocationEnabled:(CDVInvokedUrlCommand*)command
{
    NSLog(@"setLocationEnabled called");
    
    NSString *callbackId = command.callbackId;
    BOOL value = [[command.arguments objectAtIndex:0] boolValue];
    [XPush setLocationEnabled:value];
    [self successWithMessage:@"" withCallbackId:callbackId];
}

- (void) setAsksForLocationPermissions:(CDVInvokedUrlCommand *)command
{
    NSLog(@"setAsksForLocationPermissions called");
    
    NSString *callbackId = command.callbackId;
    BOOL value = [[command.arguments objectAtIndex:0] boolValue];
    [XPush setAsksForLocationPermissions:value];
    
    [self successWithMessage:@"" withCallbackId:callbackId];
}

- (void) hitTag:(CDVInvokedUrlCommand *)command
{
    NSLog(@"hitTag called");
    
    NSString *callbackId = command.callbackId;
    
    NSString *tag = [command.arguments objectAtIndex:0];
    [XPush hitTag:tag];
    
    [self successWithMessage:@"" withCallbackId:callbackId];
}

- (void) hitImpression:(CDVInvokedUrlCommand *)command
{
    NSLog(@"hitImpression called");
    
    NSString *callbackId = command.callbackId;
    
    NSString *impression = [command.arguments objectAtIndex:0];
    [XPush hitImpression:impression];
    
    [self successWithMessage:@"" withCallbackId:callbackId];
}

- (void) showPushListController:(CDVInvokedUrlCommand *)command
{
    [XPush showPushListController];
}


-(void) getPushNotificationsOffset:(CDVInvokedUrlCommand *)command
{
    NSString *callbackId = command.callbackId;
    
    NSUInteger offset = [[command.arguments objectAtIndex:0] intValue];
    NSUInteger limit = [[command.arguments objectAtIndex:1] intValue];
    
    [XPush getPushNotificationsOffset:offset limit:limit completion:^(NSArray *pushList, NSError *error) {
        if (error){
            [self failWithMessage:@"" withError:error withCallbackId:callbackId];
            return;
        }
        
        NSLog(@"in the block");
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for ( XPPushModel *model in pushList){
            [array addObject:[self convertModelToDicitionary:model]];
        }
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [self successWithMessage:jsonString withCallbackId:callbackId];
    }];
}

- (void) didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [XPush applicationDidFailToRegisterForRemoteNotificationsWithError:error];
    
    [self failWithMessage:@"" withError:error withCallbackId:asyncCallbackId];
}

- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [XPush applicationDidRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    [self successWithMessage:[NSString stringWithFormat:@"%@", token] withCallbackId:self.asyncCallbackId];
}

- (void) notificationReceived
{
    NSLog(@"Notification received");
    
    if (self.showAlerts){
        [XPush applicationDidReceiveRemoteNotification:self.notificationMessage showAlert:self.showAlerts];
    } else {
        [XPush applicationDidReceiveRemoteNotification:self.notificationMessage];
    }
    
    if (self.notificationMessage && self.callback)
    {
        NSMutableString *jsonStr = [NSMutableString stringWithString:@"{"];
        
        [self parseDictionary:self.notificationMessage intoJSON:jsonStr];
        
        if (isInline)
        {
            [jsonStr appendFormat:@"foreground:\"%d\"", 1];
            isInline = NO;
        }
		else
            [jsonStr appendFormat:@"foreground:\"%d\"", 0];
        
        [jsonStr appendString:@"}"];
        
        NSLog(@"Msg: %@", jsonStr);
        
        NSString * jsCallBack = [NSString stringWithFormat:@"%@(%@);", self.callback, jsonStr];
        [self.webView stringByEvaluatingJavaScriptFromString:jsCallBack];
        
        self.notificationMessage = nil;
    }
}

// reentrant method to drill down and surface all sub-dictionaries' key/value pairs into the top level json
- (void) parseDictionary:(NSDictionary *)inDictionary intoJSON:(NSMutableString *)jsonString
{
    NSArray         *keys = [inDictionary allKeys];
    NSString        *key;
    
    for (key in keys)
    {
        id thisObject = [inDictionary objectForKey:key];
        
        if ([thisObject isKindOfClass:[NSDictionary class]])
        [self parseDictionary:thisObject intoJSON:jsonString];
        else if ([thisObject isKindOfClass:[NSString class]])
        [jsonString appendFormat:@"\"%@\":\"%@\",",
         key,
         [[[[inDictionary objectForKey:key]
            stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
           stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]
          stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"]];
        else {
            [jsonString appendFormat:@"\"%@\":\"%@\",", key, [inDictionary objectForKey:key]];
        }
    }
}

//converting XPPushModel to NSMutableDictionaty.
//used to transfer list to javascript side of the application
- (NSMutableDictionary *) convertModelToDicitionary:(XPPushModel *)model
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (model.createDate != nil){
        [dict setValue:
         [NSDateFormatter localizedStringFromDate:model.createDate
                                dateStyle:NSDateFormatterShortStyle
                                timeStyle:NSDateFormatterFullStyle]
                                forKey:@"createdDate"];
    }
    
    if (model.pushId != nil){
        [dict setValue:model.pushId forKey:@"pushId"];
    }
    
    if (model.locationId != nil){
        [dict setValue:model.locationId forKey:@"locationId"];
    }
    
    if (model.alert != nil){
        [dict setValue:model.alert forKey:@"alert"];
    }
    
    if (model.messageId != nil){
        [dict setValue:model.messageId forKey:@"messageId"];
    }
    
    if (model.url != nil){
        [dict setValue:model.url forKey:@"url"];
    }
    
    [dict setValue:[NSNumber numberWithBool:model.shouldOpenInApp] forKey:@"shouldOpenInApp"];
    [dict setValue:[NSNumber numberWithBool:model.isRead] forKey:@"isRead"];
    [dict setValue:[NSNumber numberWithInt:model.badge] forKey:@"badge"];
    
    return dict;
}


- (void) successWithMessage:(NSString *)message withCallbackId:(NSString *)callback
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    
    [self.commandDelegate sendPluginResult:commandResult callbackId:callback];
}

- (void) failWithMessage:(NSString *)message withError:(NSError *)error withCallbackId:(NSString *)callback
{
    NSString        *errorMessage = (error) ? [NSString stringWithFormat:@"%@ - %@", message, [error localizedDescription]] : message;
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
    
    [self.commandDelegate sendPluginResult:commandResult callbackId:callback];
}

@end
