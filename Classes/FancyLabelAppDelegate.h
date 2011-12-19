//
//  FancyLabelAppDelegate.h
//  FancyLabel
//
//  Created by Craig Hockenberry on 10/1/08.
//  Copyright The Iconfactory 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FancyLabelViewController;

@interface FancyLabelAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    FancyLabelViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FancyLabelViewController *viewController;

@end

