#import "FURootListController.h"

// preferred height should be at least half header height
#define HEADER_HEIGHT 320.0
#define HEADER_MARGIN 20.0
#define PREFERRED_HEIGHT ((HEADER_HEIGHT / 2.0) + HEADER_MARGIN)

@implementation FURootListController

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	[super setPreferenceValue:value specifier:specifier];

	id tweakEnabledSpecifier = [self specifierForID:@"FUTweakEnabled"];

	if (specifier == tweakEnabledSpecifier)
	{
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),CFSTR(FU_UPDATE_SWITCH_NOTIFICATION),NULL,NULL,TRUE);
	}
}

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"FolderUsagePrefs" target:self];

#if 0
		CFNotificationCenterAddObserver(
			CFNotificationCenterGetDarwinNotifyCenter(),
			NULL,
			switchChanged,
			CFSTR(FU_UPDATE_SETTINGS_NOTIFICATION),
			NULL,
			CFNotificationSuspensionBehaviorCoalesce
		);
#endif
	}

	return _specifiers;
}

#if 0
static void switchChanged(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
	[self loadSettings];

	id tweakEnabledSpecifier = [self specifierForID:@"FUTweakEnabled"];

	if (tweakEnabledSpecifier)
		[self reloadSpecifier:tweakEnabledSpecifier animated:YES];
}
#endif

- (void)viewDidLoad
{
	[super viewDidLoad];

	CGRect frame = CGRectMake(0,0,self.table.bounds.size.width,PREFERRED_HEIGHT);

//	UIImage *headerImage = [[[UIImage alloc]
//		initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/FolderUsagePrefs.bundle"] pathForResource:@"FolderUsageHeader" ofType:@"png"]] autorelease];
	UIImage *headerImage = [[UIImage alloc]
		initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/FolderUsagePrefs.bundle"] pathForResource:@"FolderUsageHeader" ofType:@"png"]];

//	UIImageView *headerView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
	UIImageView *headerView = [[UIImageView alloc] initWithFrame:frame];

	[headerView setImage:headerImage];
	[headerView setBackgroundColor:[UIColor darkGrayColor]];
	[headerView setContentMode:UIViewContentModeCenter];
	[headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

	self.table.tableHeaderView = headerView;
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];

	CGRect wrapperFrame = ((UIView *)self.table.subviews[0]).frame; // UITableViewWrapperView
	CGRect frame = CGRectMake(wrapperFrame.origin.x,self.table.tableHeaderView.frame.origin.y,wrapperFrame.size.width,self.table.tableHeaderView.frame.size.height);

	self.table.tableHeaderView.frame = frame;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1
{
	return PREFERRED_HEIGHT;
}

@end

// vim:ft=objc
