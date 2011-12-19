//
//  FancyLabelAppDelegate.m
//  FancyLabel
//
//  Created by Craig Hockenberry on 10/1/08.
//  Copyright The Iconfactory 2008. All rights reserved.
//

#import "FancyLabelAppDelegate.h"
#import "FancyLabelViewController.h"

@implementation FancyLabelAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch
	self.viewController = [[[FancyLabelViewController alloc] init] autorelease];
  
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
