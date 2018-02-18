// preference definitions
#define FU_BUNDLE_ID						"org.midey.folderusage"
#define FU_PREFS_DIRECTORY					"/var/mobile/Library/Preferences"
#define FU_PREFS_FILE						FU_PREFS_DIRECTORY "/" FU_BUNDLE_ID ".plist"
#define FU_PREFS_CHANGED_NOTIFICATION		FU_BUNDLE_ID "/settingsChanged"

// localization definitions
#define FU_TWEAK_BUNDLE						"/Library/Application Support/FolderUsage.bundle"

// preference defaults
#define FU_DEFAULT_TWEAK_ENABLED			YES
#define FU_DEFAULT_DISK_USAGE_TYPE			kDiskUsageTotal
#define FU_DEFAULT_SHOW_APP_USAGE			YES
#define FU_DEFAULT_APP_SORT_TYPE			kSortBySize
#define FU_DEFAULT_APP_SORT_ORDER			kSortDescending
#define FU_DEFAULT_SHOW_SUBFOLDER_USAGE		YES
#define FU_DEFAULT_SUBFOLDER_SORT_TYPE		kSortBySize
#define FU_DEFAULT_SUBFOLDER_SORT_ORDER		kSortDescending

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

typedef NS_ENUM(NSUInteger,SortOrder)
{
	kSortAscending = 0,
	kSortDescending
};

@interface FUPreferences : NSObject
{
	NSMutableDictionary *settings;
}
@property(nonatomic) BOOL tweakEnabled;

@property(nonatomic) NSInteger diskUsageType;

@property(nonatomic) BOOL showAppUsage;
@property(nonatomic) NSInteger appSortType;
@property(nonatomic) NSInteger appSortOrder;

@property(nonatomic) BOOL showSubfolderUsage;
@property(nonatomic) NSInteger subfolderSortType;
@property(nonatomic) NSInteger subfolderSortOrder;

+ (FUPreferences *)sharedInstance;
@end

// vim:ft=objc
