//
//  AppDelegate.m
//  ZDCurrencyConverter
//
//  Created by Zendesk Inc on 7/26/15.
//  Copyright (c) 2015 Steven Diviney. All rights reserved.
//

#import "AppDelegate.h"
#import <ZendeskSDK/ZendeskSDK.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.\
    
    [ZDKLogger enable:YES];
    [ZDKLogger setLogLevel:ZDKLogLevelDebug];
//    
//    ZDKAnonymousIdentity *identity = [ZDKAnonymousIdentity new];
//
//    [ZDKConfig instance].userIdentity = identity;
//    
//    
//    [[ZDKConfig instance] initializeWithAppId:@"af797f58720c91ae9efee8307e0f64fcd2ba315ca47547e0" zendeskUrl:@"https://z3ncurrencyapphelp.zendesk.com" ClientId:@"mobile_sdk_client_7f805e36e8993cf45918" onSuccess:^() {
//        
//    } onError:^(NSError *error) {
//        
//    }];
    
    ZDKJwtIdentity *identity = [[ZDKJwtIdentity alloc] initWithJwtUserIdentifier:@"testflr@example.com"];
    
    [ZDKConfig instance].userIdentity = identity;
    
    [[ZDKConfig instance] initializeWithAppId:@"e5dd7520b178e21212f5cc2751a28f4b5a7dc76698dc79bd"
                                   zendeskUrl:@"https://rememberthedate.zendesk.com"
                                  andClientId:@"client_for_rtd_jwt_endpoint"];
    
    

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
