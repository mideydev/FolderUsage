#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#import "../FUPreferences.h"

static NSString *tweakEnabledKey = @"tweakEnabled";

@interface FolderUsageSwitch : NSObject <FSSwitchDataSource>
@end

@implementation FolderUsageSwitch

NS_INLINE void settingsChanged(void)
{
	[[FSSwitchPanel sharedPanel] stateDidChangeForSwitchIdentifier:[NSBundle bundleForClass:[FolderUsageSwitch class]].bundleIdentifier];
}

+ (void)load
{
	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		(CFNotificationCallback)settingsChanged,
		CFSTR(FU_UPDATE_SWITCH_NOTIFICATION),
		NULL,
		CFNotificationSuspensionBehaviorCoalesce
	);
}

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier
{
	return @"FolderUsage";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	NSDictionary *tweakSettings = ([NSDictionary dictionaryWithContentsOfFile:@FU_PREFS_FILE] ?: [NSDictionary dictionary]);

	id tweakEnabledExists = [tweakSettings objectForKey:tweakEnabledKey];
	BOOL isTweakEnabled = tweakEnabledExists ? [tweakEnabledExists boolValue] : YES;

	return (isTweakEnabled) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
	NSMutableDictionary *tweakSettings = ([NSMutableDictionary dictionaryWithContentsOfFile:@FU_PREFS_FILE] ?: [NSMutableDictionary dictionary]);

	switch (newState)
	{
		case FSSwitchStateIndeterminate:
			return;
			break;

		case FSSwitchStateOn:
			[tweakSettings setValue:@YES forKey:tweakEnabledKey];
			break;

		case FSSwitchStateOff:
			[tweakSettings setValue:@NO forKey:tweakEnabledKey];
			break;
	}

	[tweakSettings writeToFile:@FU_PREFS_FILE atomically:YES];

	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),CFSTR(FU_RELOAD_PREFS_NOTIFICATION),NULL,NULL,TRUE);
//	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),CFSTR(FU_UPDATE_SETTINGS_NOTIFICATION),NULL,NULL,TRUE);
}

@end

// vim:ft=objc
