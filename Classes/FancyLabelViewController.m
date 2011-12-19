//
//  FancyLabelViewController.m
//  FancyLabel
//
//  Created by Craig Hockenberry on 10/1/08.
//  Copyright The Iconfactory 2008. All rights reserved.
//

#import "FancyLabelViewController.h"

@implementation FancyLabelViewController

@synthesize titleLabel;
@synthesize tweetLabel;
@synthesize linksEnabled;

// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Custom initialization
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    }
    return self;
}

// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {

	CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
	//applicationFrame.origin = CGPointZero;

	UIView *contentView = [[[UIView alloc] initWithFrame:applicationFrame] autorelease];

	[contentView setBackgroundColor:[UIColor orangeColor]];

	self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, applicationFrame.size.width - 20.0f, 32.0f)] autorelease];
	[self.titleLabel setFont:[UIFont boldSystemFontOfSize:26.0f]];
	[self.titleLabel setTextColor:[UIColor whiteColor]];
	[self.titleLabel setBackgroundColor:[UIColor clearColor]];
	[self.titleLabel setAdjustsFontSizeToFitWidth:YES];
	[self.titleLabel setText:@"Click the Switch Button"];
	[contentView addSubview:self.titleLabel];

	self.linksEnabled = NO;
	
	self.tweetLabel = [[[IFTweetLabel alloc] initWithFrame:CGRectMake(10.0f, 50.0f, applicationFrame.size.width - 20.0f, applicationFrame.size.height - 50.0f - 40.0f)] autorelease];
	[self.tweetLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
	[self.tweetLabel setTextColor:[UIColor whiteColor]];
	[self.tweetLabel setBackgroundColor:[UIColor clearColor]];
	[self.tweetLabel setNumberOfLines:0];
	[self.tweetLabel setText:@"This is a #test of regular expressions with http://example.com links as used in @Twitterrific. HTTP://CHOCKLOCK.COM APPROVED OF COURSE. +21342234 123 123456 1234567"];
	[self.tweetLabel setLinksEnabled:self.linksEnabled];
	[contentView addSubview:self.tweetLabel];

	CGRect frame = CGRectMake(100.0f, applicationFrame.size.height - 40.0f, applicationFrame.size.width - 200.0f, 22.0f);
	UIButton *switchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect]; // autoreleased
	[switchButton setFrame:frame];
	[switchButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
	[switchButton setTitle:@"Switch" forState:UIControlStateNormal];
/*
	Code like this can be used to customize the buttons that are placed on top of the label:
	 
	[switchButton setTitleColor:[UIColor colorWithRed:0.67f green:0.87f blue:0.96f alpha:1.0f] forState:UIControlStateNormal];
	[switchButton setBackgroundImage:[[UIImage imageNamed:@"link_up.png"] stretchableImageWithLeftCapWidth:11.0f topCapHeight:0.0f] forState:UIControlStateNormal];
	[switchButton setBackgroundImage:[[UIImage imageNamed:@"link_down.png"] stretchableImageWithLeftCapWidth:11.0f topCapHeight:0.0f] forState:UIControlStateHighlighted];
 */
	[switchButton addTarget:self action:@selector(switchLinksEnabled:) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:switchButton];

	self.view = contentView;
}


/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:IFTweetLabelURLNotification object:nil];

    [super dealloc];
}

- (void)switchLinksEnabled:(id)sender
{
	self.linksEnabled = !self.linksEnabled;
	
	if (self.linksEnabled)
	{
		[self.titleLabel setText:@"Links are Enabled"];
	}
	else
	{
		[self.titleLabel setText:@"Links are Disabled"];
	}
	[self.tweetLabel setLinksEnabled:self.linksEnabled];
}


- (void)handleTweetNotification:(NSNotification *)notification
{
	NSLog(@"handleTweetNotification: notification = %@", notification);
}

@end
