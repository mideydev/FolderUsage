#import "SpringBoard.h"
#import "FUPreferences.h"
#import "FUHandler.h"

%hook SBFolderIconView

%group SBFolderIconView_iOS8

- (id)initWithFrame:(struct CGRect)arg1
{
	id retval = %orig();

#ifdef DEBUG
	NSString *folderName = [[self folder] displayName];
#endif

	HBLogDebug(@"==============================[ SBFolderIconView:initWithFrame ]==============================");

	if (retval)
	{
		HBLogDebug(@"setting up icon gesture recognizer for folder: [%@]",folderName);
		UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showFolderUsage:)];
		swipe.direction = UISwipeGestureRecognizerDirectionUp;
		[self addGestureRecognizer:swipe];
		[swipe release];
	}

	return retval;
}

%end /* group SBFolderIconView_iOS8 */

%group SBFolderIconView_iOS9OrGreater

- (id)initWithContentType:(unsigned long long)arg1
{
	id retval = %orig();

#ifdef DEBUG
	NSString *folderName = [[self folder] displayName];
#endif

	HBLogDebug(@"==============================[ SBFolderIconView:initWithContentType ]==============================");

	if (retval)
	{
		HBLogDebug(@"setting up icon gesture recognizer for folder: [%@]",folderName);
		UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showFolderUsage:)];
		swipe.direction = UISwipeGestureRecognizerDirectionUp;
		[self addGestureRecognizer:swipe];
		[swipe release];
	}

	return retval;
}

%end /* group SBFolderIconView_iOS9OrGreater */

%new
- (void)showFolderUsage:(UISwipeGestureRecognizer *)swipe
{
#ifdef DEBUG
	NSString *folderName = [[self folder] displayName];
#endif

	HBLogDebug(@"showFolderUsage: [%@] : swiped",folderName);

	if (![[FUPreferences sharedInstance] tweakEnabled])
	{
		HBLogDebug(@"showFolderUsage: [%@] : ignored swipe while tweak disabled",folderName);
		return;
	}

	if ([self isEditing])
	{
		HBLogDebug(@"showFolderUsage: [%@] : ignored swipe in wiggle mode",folderName);
		return;
	}

	FUHandler *handler = [[FUHandler alloc] init];
	[handler showUsageForFolder:[self folder]];
	[handler release];
}

%end /* hook SBFolderIconView */

%hook SBRootFolderView

- (id)initWithFolder:(id)arg1 orientation:(long long)arg2 viewMap:(id)arg3 context:(id)arg4
{
	id retval = %orig();

	HBLogDebug(@"==============================[ SBRootFolderView:initWithFolder ]==============================");

	if (retval)
	{
		UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showDeviceUsage:)];
		swipe.direction = UISwipeGestureRecognizerDirectionUp;
		[self addGestureRecognizer:swipe];
		[swipe release];
	}

	return retval;
}

%new
- (void)showDeviceUsage:(UISwipeGestureRecognizer *)swipe
{
	HBLogDebug(@"showDeviceUsage: swiped");

	if (![[FUPreferences sharedInstance] tweakEnabled])
	{
		HBLogDebug(@"showDeviceUsage: ignored swipe while tweak disabled");
		return;
	}

	if (![[FUPreferences sharedInstance] deviceUsageGestureEnabled])
	{
		HBLogDebug(@"showDeviceUsage: ignored swipe while device usage gesture disabled");
		return;
	}

	if ([[%c(SBControlCenterController) sharedInstance] isVisible])
	{
		HBLogDebug(@"showDeviceUsage: ignored swipe while control center is visible");
		return;
	}

	FUHandler *handler = [[FUHandler alloc] init];
	[handler showUsageForDevice:[self folder]];
	[handler release];
}

%end /* SBRootFolderView */

%ctor
{
	/* conditional hooks */

	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0"))
	{
		%init(SBFolderIconView_iOS9OrGreater);
    }
	else
	{
		%init(SBFolderIconView_iOS8);
	}

	%init;
}

// vim:ft=objc
