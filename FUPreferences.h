// preference definitions
#define FU_BUNDLE_ID						"org.midey.folderusage"
#define FU_PREFS_DIRECTORY					"/var/mobile/Library/Preferences"
#define FU_PREFS_FILE						FU_PREFS_DIRECTORY "/" FU_BUNDLE_ID ".plist"
#define FU_RELOAD_PREFS_NOTIFICATION		FU_BUNDLE_ID "/reloadPreferences"
#define FU_UPDATE_SWITCH_NOTIFICATION		FU_BUNDLE_ID "/updateSwitch"
#define FU_UPDATE_SETTINGS_NOTIFICATION		FU_BUNDLE_ID "/updateSettings"

// localization definitions
#define FU_TWEAK_BUNDLE						"/Library/Application Support/FolderUsage.bundle"

// preference defaults
#define FU_DEFAULT_TWEAK_ENABLED					YES
#define FU_DEFAULT_DISK_USAGE_TYPE					kDiskUsageTotal
#define FU_DEFAULT_SHOW_APP_USAGE					YES
#define FU_DEFAULT_APP_NAME_TYPE					kAppLocalizedName
#define FU_DEFAULT_SHOW_APP_COUNTS					NO
#define FU_DEFAULT_APP_SORT_TYPE					kSortBySize
#define FU_DEFAULT_APP_SORT_ORDER					kSortDescending
#define FU_DEFAULT_SHOW_SUBFOLDER_USAGE				YES
#define FU_DEFAULT_SHOW_SUBFOLDER_COUNTS			NO
#define FU_DEFAULT_SUBFOLDER_SORT_TYPE				kSortBySize
#define FU_DEFAULT_SUBFOLDER_SORT_ORDER				kSortDescending
#define FU_DEFAULT_DEVICE_USAGE_GESTURE_ENABLED		NO
#define FU_DEFAULT_GROUP_BY_HOME_SCREEN_AND_DOCK	NO
#define FU_DEFAULT_FONT_SIZE						13
#define FU_DEFAULT_INDENT_SIZE						28
#define FU_DEFAULT_COPY_BUTTON_ENABLED				YES
#define FU_DEFAULT_FORCE_MODERN_ALERTS				NO

typedef NS_ENUM(NSUInteger,DiskUsageType)
{
	kDiskUsageStatic = 0,
	kDiskUsageDynamic,
	kDiskUsageTotal
};

typedef NS_ENUM(NSUInteger,SortType)
{
	kSortByNone = 0,
	kSortBySize,
	kSortByName
};

typedef NS_ENUM(NSUInteger,SortOrderType)
{
	kSortAscending = 0,
	kSortDescending
};

typedef NS_ENUM(NSUInteger,AppNameType)
{
	kAppLocalizedName = 0,
	kAppLocalizedShortName,
	kAppItemName,
	kAppIdentifier
};

@interface FUPreferences : NSObject
{
	NSMutableDictionary *settings;
}
@property(nonatomic) BOOL tweakEnabled;

@property(nonatomic) NSInteger diskUsageType;

@property(nonatomic) BOOL showAppUsage;
@property(nonatomic) BOOL showAppCounts;
@property(nonatomic) NSInteger appNameType;
@property(nonatomic) NSInteger appSortType;
@property(nonatomic) NSInteger appSortOrder;

@property(nonatomic) BOOL showSubfolderUsage;
@property(nonatomic) BOOL showSubfolderCounts;
@property(nonatomic) NSInteger subfolderSortType;
@property(nonatomic) NSInteger subfolderSortOrder;

@property(nonatomic) BOOL deviceUsageGestureEnabled;
@property(nonatomic) BOOL groupByHomeScreenAndDock;

@property(nonatomic) NSInteger fontSize;
@property(nonatomic) NSInteger indentSize;
@property(nonatomic) BOOL copyButtonEnabled;
@property(nonatomic) BOOL forceModernAlerts;

+ (FUPreferences *)sharedInstance;
@end

// vim:ft=objc
