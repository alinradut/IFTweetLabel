//
//  IFTweetLabel.h
//  TwitterrificTouch
//
//  Created by Craig Hockenberry on 4/2/08.
//  Copyright 2008 The Iconfactory. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *IFTweetLabelURLNotification;

// NOTE: Yeah, it would make more sense to subclass UILabel to do this. But all the
// the UIButtons that got placed on top of the UILabel were not tappable. No amount of
// tinkering with userInteractionEnabled and the responder chain could be found to
// work around this issue.
//
// Instead, a normal view is used and an UILabel methods are supported through forward
// invocation.

@interface IFTweetLabel : UIView 
{
	UIColor *normalColor;
	UIColor *highlightColor;

	UIImage *normalImage;
	UIImage *highlightImage;

	UILabel *label;
	
	BOOL linksEnabled;
}

@property (nonatomic, retain) UIColor *normalColor;
@property (nonatomic, retain) UIColor *highlightColor;

@property (nonatomic, retain) UIImage *normalImage;
@property (nonatomic, retain) UIImage *highlightImage;

@property (nonatomic, retain) UILabel *label;

@property (assign) BOOL linksEnabled;

- (void)setBackgroundColor:(UIColor *)backgroundColor;
- (void)setFrame:(CGRect)frame;

@end


@interface IFTweetLabel (ForwardInvocation)

@property(nonatomic, copy) NSString *text;
@property(nonatomic) NSInteger numberOfLines;
@property(nonatomic, retain) UIColor *textColor;
@property(nonatomic, retain) UIFont *font;

@end