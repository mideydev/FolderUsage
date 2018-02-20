#import "SpringBoard.h"
#import "FUPreferences.h"
#import "FUHandler.h"

%hook SBFolderIconView

- (id)initWithFrame:(struct CGRect)arg1
{
	id retval = %orig();

	HBLogDebug(@"==============================[ SBFolderIconView:initWithFrame ]==============================");

	if (retval)
	{
		UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showFolderUsage:)];
		swipe.direction = UISwipeGestureRecognizerDirectionUp;
		[self addGestureRecognizer:swipe];
		[swipe release];
	}

	return retval;
}

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

%end

%hook SBRootFolderView

#if 0
- (id)initWithFolder:(id)arg1 orientation:(long long)arg2 viewMap:(id)arg3
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
#endif

#if 0
- (id)initWithFolder:(id)arg1 orientation:(long long)arg2 viewMap:(id)arg3 forSnapshot:(_Bool)arg4
{
	id retval = %orig();

	HBLogDebug(@"==============================[ SBRootFolderView:initWithFolder (forSnapshot) ]==============================");

	if (retval)
	{
		UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showDeviceUsage:)];
		swipe.direction = UISwipeGestureRecognizerDirectionUp;
		[self addGestureRecognizer:swipe];
		[swipe release];
	}

	return retval;
}
#endif

- (id)initWithFolder:(id)arg1 orientation:(long long)arg2 viewMap:(id)arg3 context:(id)arg4
{
	id retval = %orig();

	HBLogDebug(@"==============================[ SBRootFolderView:initWithFolder (context) ]==============================");

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

%end

// vim:ft=objc