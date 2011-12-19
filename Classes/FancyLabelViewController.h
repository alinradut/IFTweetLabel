//
//  FancyLabelViewController.h
//  FancyLabel
//
//  Created by Craig Hockenberry on 10/1/08.
//  Copyright The Iconfactory 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IFTweetLabel.h"

@interface FancyLabelViewController : UIViewController {

	UILabel *titleLabel;
	
	IFTweetLabel *tweetLabel;
	BOOL linksEnabled;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) IFTweetLabel *tweetLabel;
@property (assign) BOOL linksEnabled;

@end

