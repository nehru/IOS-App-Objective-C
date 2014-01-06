//
//  Global.m
//  Bringo
//
//  Created by Nehru Sathappan on 5/17/13.
//  Copyright (c) 2013 Nehru Sathappan. All rights reserved.
//

#import "Global.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <SystemConfiguration/SCNetworkReachability.h>
 

@implementation Global
 

- (BOOL) connectedToNetwork
{
	// Create zero addy
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
	// Recover reachability flags
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags;
    
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
    
	if (!didRetrieveFlags)
	{
		return NO;
	}
    
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	return (isReachable && !needsConnection) ? YES : NO;
}

//call like:
-(BOOL) start {
	if (![self connectedToNetwork]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Network Connection Error"
                              message:@"Please connect to the internet to use this program."
                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
        
        return false;
    } else {
        //do something
        return true;
    }
}

@end
