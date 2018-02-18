#import <Foundation/Foundation.h>
#import "FUPreferences.h"

@implementation FUPreferences

static void settingsChanged(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
	[[FUPreferences sharedInstance] refreshSettings];
	[[FUPreferences sharedInstance] loadSettings];
}

- (FUPreferences *)init
{
	self = [super init];

	if (self)
	{
	}

	return self;
}

/*
- (void)dealloc
{
	if (settings)
		[settings release];

	[super dealloc];
}
*/

+ (FUPreferences *)sharedInstance
{
	static FUPreferences *sharedInstance = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[FUPreferences alloc] init];
		// Do any other initialisation stuff here

		[sharedInstance loadInitialSettings];

		CFNotificationCenterAddObserver(
			CFNotificationCenterGetDarwinNotifyCenter(),
			NULL,
			settingsChanged,
			CFSTR(FU_PREFS_CHANGED_NOTIFICATION),
			NULL,
			CFNotificationSuspensionBehaviorCoalesce
		);
	});

	return sharedInstance;
}

- (void)logSettings
{
	HBLogDebug(@"[logSettings] ---------------------------------------------");
	HBLogDebug(@"[logSettings] self.tweakEnabled                     = %@",self.tweakEnabled?@"YES":@"NO");
	HBLogDebug(@"[logSettings] self.diskUsageType                    = %ld",(long)self.diskUsageType);
	HBLogDebug(@"[logSettings] self.showAppUsage                     = %@",self.showAppUsage?@"YES":@"NO");
	HBLogDebug(@"[logSettings] self.appSortType                      = %ld",(long)self.appSortType);
	HBLogDebug(@"[logSettings] self.appSortOrder                 = %ld",(long)self.appSortOrder);
	HBLogDebug(@"[logSettings] self.showSubfolderUsage               = %@",self.showSubfolderUsage?@"YES":@"NO");
	HBLogDebug(@"[logSettings] self.subfolderSortType                = %ld",(long)self.subfolderSortType);
	HBLogDebug(@"[logSettings] self.subfolderSortOrder           = %ld",(long)self.subfolderSortOrder);
}

- (void)loadInitialSettings
{
	self.tweakEnabled = FU_DEFAULT_TWEAK_ENABLED;
	self.diskUsageType = FU_DEFAULT_DISK_USAGE_TYPE;
	self.showAppUsage = FU_DEFAULT_SHOW_APP_USAGE;
	self.appSortType = FU_DEFAULT_APP_SORT_TYPE;
	self.appSortOrder = FU_DEFAULT_APP_SORT_ORDER;
	self.showSubfolderUsage = FU_DEFAULT_SHOW_SUBFOLDER_USAGE;
	self.subfolderSortType = FU_DEFAULT_SUBFOLDER_SORT_TYPE;
	self.subfolderSortOrder = FU_DEFAULT_SUBFOLDER_SORT_ORDER;

	[self logSettings];

	[self refreshSettings];
	[self loadSettings];

	[self logSettings];
}

- (void)loadSettings
{
	if (settings)
	{
		id pref;

		if ((pref = [settings objectForKey:@"tweakEnabled"])) self.tweakEnabled = [pref boolValue];
		if ((pref = [settings objectForKey:@"diskUsageType"])) self.diskUsageType = [pref integerValue];
		if ((pref = [settings objectForKey:@"showAppUsage"])) self.showAppUsage = [pref boolValue];
		if ((pref = [settings objectForKey:@"appSortType"])) self.appSortType = [pref integerValue];
		if ((pref = [settings objectForKey:@"appSortOrder"])) self.appSortOrder = [pref integerValue];
		if ((pref = [settings objectForKey:@"showSubfolderUsage"])) self.showSubfolderUsage = [pref boolValue];
		if ((pref = [settings objectForKey:@"subfolderSortType"])) self.subfolderSortType = [pref integerValue];
		if ((pref = [settings objectForKey:@"subfolderSortOrder"])) self.subfolderSortOrder = [pref integerValue];

		[self logSettings];
	}
}

- (void)refreshSettings
{
/*
	if (settings)
	{
		[settings release];
		settings = nil;
	}
*/

	settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@FU_PREFS_FILE];
}

@end

// vim:ft=objc
