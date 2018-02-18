#import "FURootListController.h"

// preferred height should be at least half header height
#define HEADER_HEIGHT 320.0
#define HEADER_MARGIN 20.0
#define PREFERRED_HEIGHT ((HEADER_HEIGHT / 2.0) + HEADER_MARGIN)

@implementation FURootListController

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	[super setPreferenceValue:value specifier:specifier];

//	[self synchronizeSLSUniversalCourses:value specifier:specifier];
}

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"FolderUsagePrefs" target:self];
	}

	return _specifiers;
}

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

#if 0
- (void)synchronizeSLSUniversalCourse:(id)value specifier:(PSSpecifier *)specifier course:(id)course
{
	if (specifier == course)
		return;

	[super setPreferenceValue:value specifier:course];
	[self reloadSpecifier:course animated:YES];
}

- (void)synchronizeSLSUniversalCourses:(id)value specifier:(PSSpecifier *)specifier
{
	id course1 = [self specifierForID:@"FUPurifySkateparkSLS2012Hangar"];
	id course2 = [self specifierForID:@"FUPurifySkateparkSLS2015LosAngeles"];
	id course3 = [self specifierForID:@"FUPurifySkateparkSLS2015NewJersey"];
	id course4 = [self specifierForID:@"FUPurifySkateparkSLS2015SuperCrown"];
	id course5 = [self specifierForID:@"FUPurifySkateparkSLS2016Munich"];

	if ((specifier != course1) && (specifier != course2) && (specifier != course3) && (specifier != course4) && (specifier != course5))
		return;

	[self synchronizeSLSUniversalCourse:value specifier:specifier course:course1];
	[self synchronizeSLSUniversalCourse:value specifier:specifier course:course2];
	[self synchronizeSLSUniversalCourse:value specifier:specifier course:course3];
	[self synchronizeSLSUniversalCourse:value specifier:specifier course:course4];
	[self synchronizeSLSUniversalCourse:value specifier:specifier course:course5];
}
#endif

@end

// vim:ft=objc
