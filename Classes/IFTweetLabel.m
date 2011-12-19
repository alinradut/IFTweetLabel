//
//  IFTweetLabel.m
//  TwitterrificTouch
//
//  Created by Craig Hockenberry on 4/2/08.
//  Copyright 2008 The Iconfactory. All rights reserved.
//

#import "IFTweetLabel.h"

#import "RKLMatchEnumerator.h"


#define DRAW_DEBUG_FRAMES 0


@implementation IFTweetLabel

@synthesize normalColor;
@synthesize highlightColor;

@synthesize normalImage;
@synthesize highlightImage;

@synthesize label;

@synthesize linksEnabled;


NSString *IFTweetLabelURLNotification = @"IFTweetLabelURLNotification";


static NSArray *expressions = nil;

+ (void)initialize
{
	// setup regular expressions that define where buttons will be created
	expressions = [[NSArray alloc] initWithObjects:
                   @"(\\+)?([0-9]{8,}+)", // phone numbers, 8 or more
                   @"(@[a-zA-Z0-9_]+)", // screen names
			@"(#[a-zA-Z0-9_-]+)", // hash tags
			@"([hH][tT][tT][pP][sS]?:\\/\\/[^ ,'\">\\]\\)]*[^\\. ,'\">\\]\\)])", // hyperlinks
			nil];
}

- (void)handleButton:(id)sender
{
	NSString *buttonTitle = [sender titleForState:UIControlStateNormal];
	//NSLog(@"IFTweetLabel: handleButton: sender = %@, title = %@", sender, buttonTitle);

	NSString *text = self.label.text;

	// NOTE: It's possible that the button title only includes the beginning of screen name or hyperlink.
	// This code collects all possible links in the current label text and gets a full match that can be passed
	// with the notification.
	
	for (NSString *expression in expressions)
	{
		NSString *match;
		NSEnumerator *enumerator = [text matchEnumeratorWithRegex:expression];
		while (match = [enumerator nextObject])
		{
			if ([match hasPrefix:buttonTitle])
			{
				[[NSNotificationCenter defaultCenter] postNotificationName:IFTweetLabelURLNotification object:match];
			}
		}
	}
}

- (void)createButtonWithText:(NSString *)text withFrame:(CGRect)frame
{
	UIButton *button = nil;
	if (self.normalImage && self.highlightImage)
	{
		button = [UIButton buttonWithType:UIButtonTypeCustom]; // autoreleased
		[button setBackgroundImage:self.normalImage forState:UIControlStateNormal];
		[button setBackgroundImage:self.highlightImage forState:UIControlStateHighlighted];
	}
	else
	{
		button = [UIButton buttonWithType:UIButtonTypeRoundedRect]; // autoreleased
	}
	[button setFrame:frame];
	[button.titleLabel setFont:self.label.font];
	[button setTitle:text forState:UIControlStateNormal];
	[button.titleLabel setLineBreakMode:[self.label lineBreakMode]];
	[button setTitleColor:self.normalColor forState:UIControlStateNormal];
	[button setTitleColor:self.highlightColor forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:button];
}				


- (void)createButtonsWithText:(NSString *)text atPoint:(CGPoint)point
{
	//NSLog(@"output = '%@', point = %@", text, NSStringFromCGPoint(point));

	UIFont *font = self.label.font;

	for (NSString *expression in expressions)
	{
		NSString *match;
		NSEnumerator *enumerator = [text matchEnumeratorWithRegex:expression];
		while (match = [enumerator nextObject])
		{
			CGSize matchSize = [match sizeWithFont:font];

			NSRange matchRange = [text rangeOfString:match];
			NSRange measureRange = NSMakeRange(0, matchRange.location);
			NSString *measureText = [text substringWithRange:measureRange];
			CGSize measureSize = [measureText sizeWithFont:font];
			
			CGRect matchFrame = CGRectMake(measureSize.width - 3.0f, point.y, matchSize.width + 6.0f, matchSize.height);
			[self createButtonWithText:match withFrame:matchFrame];
			
			//NSLog(@"match = %@", match);
		}
	}
}

// NOTE: It seems that UILabel doesn't break at whitespace if it's at the beginning of the line. This value is a total fricken' guess. 
#define MIN_WHITESPACE_LOCATION 5

- (void)createButtons
{
	CGRect frame = self.frame;
	if (frame.size.width == 0.0f || frame.size.height == 0.0f)
	{
		return;
	}
	
	UIFont *font = self.label.font;
		
	
	NSString *text = self.label.text;
	NSUInteger textLength = [text length];

	// by default, the output starts at the top of the frame
	CGPoint outputPoint = CGPointZero;
	CGSize textSize = [text sizeWithFont:font constrainedToSize:frame.size];
	CGRect bounds = [self bounds];
	if (textSize.height < bounds.size.height)
	{
		// the lines of text are centered in the bounds, so adjust the output point
		CGFloat boundsMidY = CGRectGetMidY(bounds);
		CGFloat textMidY = textSize.height / 2.0;
		outputPoint.y = ceilf(boundsMidY - textMidY);
	}

	
	//NSLog(@"****** text = '%@'", text);
	
	// initialize whitespace tracking
	BOOL scanningWhitespace = NO;
	NSRange whitespaceRange = NSMakeRange(NSNotFound, 0);
	
	// scan the text
	NSRange scanRange = NSMakeRange(0, 1);
	while (NSMaxRange(scanRange) < textLength)
	{
		NSRange tokenRange = NSMakeRange(NSMaxRange(scanRange) - 1, 1);
		NSString *token = [text substringWithRange:tokenRange];

#if 0
		// debug bytes in token
		char buffer[10];
		NSUInteger usedLength;
		[token getBytes:&buffer maxLength:10 usedLength:&usedLength encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(0, [token length]) remainingRange:NULL];
		NSUInteger index;
		for (index = 0; index < usedLength; index++)
		{
			NSLog(@"token: %3d 0x%02x", tokenRange.location, buffer[index] & 0xff);
		}
#endif
		
		if ([token isEqualToString:@" "] || [token isEqualToString:@"?"] || [token isEqualToString:@"-"])
		{
			//NSLog(@"------ whitespace: token = '%@'", token);
			
			// handle whitespace
			if (! scanningWhitespace)
			{
				// start of whitespace
				whitespaceRange.location = tokenRange.location;
				whitespaceRange.length = 1;
			}
			else
			{
				// continuing whitespace
				whitespaceRange.length += 1;
			}

			scanningWhitespace = YES;
			
			// scan the next position
			scanRange.length += 1;
		}
		else
		{
			// end of whitespace
			scanningWhitespace = NO;

			NSString *scanText = [text substringWithRange:scanRange];
			CGSize currentSize = [scanText sizeWithFont:font];
			
			BOOL breakLine = NO;
			if ([token isEqualToString:@"\r"] || [token isEqualToString:@"\n"])
			{
				// carriage return or newline caused line to break
				//NSLog(@"------ scanText = '%@', token = '%@'", scanText, token);
				breakLine = YES;
			}
			BOOL breakWidth = NO;
			if (currentSize.width > frame.size.width)
			{
				// the width of the text in the frame caused the line to break
				//NSLog(@"------ scanText = '%@', currentSize = %@", scanText, NSStringFromCGSize(currentSize));
				breakWidth = YES;
			}
			
			if (breakLine || breakWidth)
			{
				// the line broke, compute the range of text we want to output
				NSRange outputRange;
				
				if (breakLine)
				{
					// output before the token that broke the line
					outputRange.location = scanRange.location;
					outputRange.length = tokenRange.location - scanRange.location;
				}
				else
				{
					if (whitespaceRange.location != NSNotFound && whitespaceRange.location > MIN_WHITESPACE_LOCATION)
					{
						// output before beginning of the last whitespace
						outputRange.location = scanRange.location;
						outputRange.length = whitespaceRange.location - scanRange.location;
					}
					else
					{
						// output before the token that cause width overflow
						outputRange.location = scanRange.location;
						outputRange.length = tokenRange.location - scanRange.location;
					}
				}
				
				// make the buttons in this line of text
				[self createButtonsWithText:[text substringWithRange:outputRange] atPoint:outputPoint];

				if (breakLine)
				{
					// start scanning after token that broke the line
					scanRange.location = NSMaxRange(tokenRange);
					scanRange.length = 1;
				}
				else
				{
					if (whitespaceRange.location != NSNotFound && whitespaceRange.location > MIN_WHITESPACE_LOCATION)
					{
						// start scanning at end of last whitespace
						scanRange.location = NSMaxRange(whitespaceRange);
						scanRange.length = 1;
					}
					else
					{
						// start scanning at token that cause width overflow
						scanRange.location = NSMaxRange(tokenRange) - 1;
						scanRange.length = 1;
					}
				}

				// reset whitespace
				whitespaceRange.location = NSNotFound;
				whitespaceRange.length = 0;
				
				// move output to next line
				outputPoint.y += currentSize.height;
			}
			else
			{
				// the line did not break, scan the next position
				scanRange.length += 1;
			}
		}
	}
	
	// output to end
	[self createButtonsWithText:[text substringFromIndex:scanRange.location] atPoint:outputPoint];;
}

- (void)removeButtons
{
	UIView *view;
	for (view in [self subviews])
	{
		if ([view isKindOfClass:[UIButton class]])
		{
			[view removeFromSuperview];
		}
	}
}


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		self.clipsToBounds = YES;
		
		self.normalColor = [UIColor blueColor];
		self.highlightColor = [UIColor redColor];
		
		self.normalImage = nil;
		self.highlightImage = nil;
	
		self.label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)] autorelease];
		[self addSubview:self.label];

		self.linksEnabled = NO;
    }
	
    return self;
}

- (void)dealloc
{
	self.normalColor = nil;
	self.highlightColor = nil;

	self.normalImage = nil;
	self.highlightImage = nil;
	
	[self removeButtons];
	
	[super dealloc];
}


- (void)layoutSubviews
{
    [super layoutSubviews];

	[self removeButtons];
	if (linksEnabled)
	{
		[self createButtons];
	}

#if DRAW_DEBUG_FRAMES
	[self setNeedsDisplay];
#endif
}

#if DRAW_DEBUG_FRAMES
- (void)drawRect:(CGRect)rect
{
	[[UIColor whiteColor] set];
	UIRectFrame([self bounds]);

	UIView *view;
	for (view in [self subviews])
	{
		if ([view isKindOfClass:[UIButton class]])
		{
			[[UIColor redColor] set];
			UIRectFrame([view frame]);
		}
		else if ([view isKindOfClass:[UILabel class]])
		{
			[[UIColor greenColor] set];
			UIRectFrame([view frame]);
		}
	}
}
#endif


- (void)setText:(NSString *)text
{
	[self.label setText:text];

	[self setNeedsLayout];
}

- (void)setLinksEnabled:(BOOL)state
{
	if (linksEnabled != state)
	{
		linksEnabled = state;

		[self setNeedsLayout];
	}
}	

// handle methods that affect both this view and label view

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
	[super setBackgroundColor:backgroundColor];
	[self.label setBackgroundColor:backgroundColor];
}

- (void)setFrame:(CGRect)frame;
{
	[super setFrame:frame];
	[self.label setFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
}

// forward methods that are not handled by the super class to the label view

- (void)forwardInvocation:(NSInvocation*)invocation
{
	SEL aSelector = [invocation selector];

	//NSLog(@"forwardInvocation: selector = %@", NSStringFromSelector(aSelector));

	if ([self.label respondsToSelector:aSelector])
	{
		[invocation invokeWithTarget:self.label];
	}
	else
	{
		[self doesNotRecognizeSelector:aSelector];
	}
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	//NSLog(@"methodSignatureForSelector: selector = %@", NSStringFromSelector(aSelector));

	NSMethodSignature* methodSignature = [super methodSignatureForSelector:aSelector];
	if (methodSignature == nil)
	{
		methodSignature = [self.label methodSignatureForSelector:aSelector];
	}
	
	return methodSignature;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	//NSLog(@"respondsToSelector: selector = %@", NSStringFromSelector(aSelector));
	
	return [super respondsToSelector:aSelector] || [self.label respondsToSelector:aSelector];
}

@end
