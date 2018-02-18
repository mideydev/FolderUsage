#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "SpringBoard.h"
#import "FUHandler.h"
#import "FUPreferences.h"
#import "external/UIAlertController+Window/UIAlertController+Window.h"

#define SYSTEM_VERSION_EQUAL_TO(v)					([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)				([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)	([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)					([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)		([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define FULocalizedStringForKey(key) [self.tweakBundle localizedStringForKey:key value:@"" table:nil]

#if 0
@"\u25A3" - square with black square inside
@"\u2023" - triangle bullet point
@"\u2043" - hyphen bullet point
@"\u2022" - circle bullet point
@"\u25BE" - Black Down-Pointing Small Triangle
@"\u25B8" - Black Right-Pointing Small Triangle
#endif

#define INDENT_STRING	@"\t"
#define FOLDER_SYMBOL	@"\u25BE"
#define APP_SYMBOL		@"\u25B8"

@interface DiskUsageInfo : NSObject
@property(nonatomic,copy) NSString *itemName;
@property(nonatomic) unsigned long long diskUsage;
@property(nonatomic,strong) NSMutableArray *containedApps;
@property(nonatomic,strong) NSMutableArray *containedFolders;
@end

@implementation DiskUsageInfo

- (DiskUsageInfo *)init
{
	self = [super init];

	if (self)
	{
		_itemName = nil;
		_diskUsage = 0;
		_containedApps = nil;
		_containedFolders = nil;
	}

	return self;
}

@end

@interface AlertInfo : NSObject
@property(nonatomic) BOOL useAlertView;
@property(nonatomic,copy) NSString *alertTitle;
@property(nonatomic,copy) NSString *alertAction;
@property(nonatomic,copy) NSString *initialAlertMessage;
@property(nonatomic,copy) NSString *alertMessage;
@property(nonatomic,copy) NSAttributedString *attributedAlertMessage;
@end

@implementation AlertInfo

- (AlertInfo *)init
{
	self = [super init];

	if (self)
	{
		_useAlertView = NO;
		_alertTitle = nil;
		_alertAction = nil;
		_initialAlertMessage = nil;
		_alertMessage = nil;
		_attributedAlertMessage = nil;
	}

	return self;
}

@end

@interface FolderUsageInfo : NSObject
@property(nonatomic,strong) DiskUsageInfo *diskUsage;
@property(nonatomic,strong) AlertInfo *alert;
@property(nonatomic) BOOL folderOnly;
@end

@implementation FolderUsageInfo

- (FolderUsageInfo *)init
{
	self = [super init];

	if (self)
	{
		_diskUsage = nil;
		_alert = nil;
		_folderOnly = NO;
	}

	return self;
}

@end

@implementation FUHandler

- (FUHandler *)init
{
	self = [super init];

	if (self)
	{
		_tweakBundle = [NSBundle bundleWithPath:@FU_TWEAK_BUNDLE];
	}

	return self;
}

- (DiskUsageInfo *)getUsageForApplication:(NSString *)applicationIdentifier
{
	DiskUsageInfo *appDiskUsage = [[DiskUsageInfo alloc] init];

	appDiskUsage.itemName = applicationIdentifier;

	appDiskUsage.diskUsage = 0;

	LSApplicationProxy *proxy = [objc_getClass("LSApplicationProxy") applicationProxyForIdentifier:applicationIdentifier];

	if (proxy)
	{
		appDiskUsage.itemName = [proxy localizedName];

		switch ([[FUPreferences sharedInstance] diskUsageType])
		{
			case kDiskUsageStatic:
				appDiskUsage.diskUsage = [[proxy staticDiskUsage] longLongValue];
				break;

			case kDiskUsageDynamic:
				appDiskUsage.diskUsage = [[proxy dynamicDiskUsage] longLongValue];
				break;

			case kDiskUsageTotal:
			default:
				appDiskUsage.diskUsage = [[proxy staticDiskUsage] longLongValue] + [[proxy dynamicDiskUsage] longLongValue];
				break;
		}
	}

	return appDiskUsage;
}

- (DiskUsageInfo *)getUsageForFolder:(id)folder
{
#ifdef DEBUG
	NSString *swipedFolder = [folder displayName];
#endif

	DiskUsageInfo *folderDiskUsage = [[DiskUsageInfo alloc] init];

	folderDiskUsage.itemName = [folder displayName];
	folderDiskUsage.diskUsage = 0;
	folderDiskUsage.containedApps = [[NSMutableArray alloc] init];
	folderDiskUsage.containedFolders = [[NSMutableArray alloc] init];

	NSArray *lists = [folder lists];

	for (SBIconListModel *list in lists)
	{
		for (id icon in [list icons])
		{
			if ([icon isKindOfClass:NSClassFromString(@"SBApplicationIcon")])
			{
				HBLogDebug(@"getUsageForFolder: [%@] : [%@] icon: %@ (app)",swipedFolder,folderDiskUsage.itemName,NSStringFromClass([icon class]));

				DiskUsageInfo *thisAppUsageInfo = [self getUsageForApplication:[icon applicationBundleID]];

				folderDiskUsage.diskUsage += thisAppUsageInfo.diskUsage;

				[folderDiskUsage.containedApps addObject:thisAppUsageInfo];
			}
			else if ([icon isKindOfClass:NSClassFromString(@"SBFolderIcon")])
			{
				HBLogDebug(@"getUsageForFolder: [%@] : [%@] icon: %@ (folder)",swipedFolder,folderDiskUsage.itemName,NSStringFromClass([icon class]));

				DiskUsageInfo *thisFolderUsageInfo = [self getUsageForFolder:[icon folder]];

				folderDiskUsage.diskUsage += thisFolderUsageInfo.diskUsage;

				[folderDiskUsage.containedFolders addObject:thisFolderUsageInfo];
			}
			else
			{
				HBLogDebug(@"getUsageForFolder: [%@] : [%@] icon: %@ (unknown)",swipedFolder,folderDiskUsage.itemName,NSStringFromClass([icon class]));
			}
		}
	}

	return folderDiskUsage;
}

- (NSMutableArray *)sortDiskUsageArray:(NSMutableArray *)diskUsageArray sortType:(NSInteger)sortType sortOrder:(NSInteger)sortOrder
{
	NSMutableArray *sortedDiskUsageArray = diskUsageArray;

	switch (sortType)
	{
		case kSortBySize:
			switch (sortOrder)
			{
				case kSortAscending:
					sortedDiskUsageArray = 
						(NSMutableArray *)[diskUsageArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
							NSNumber *first = @([(DiskUsageInfo *)a diskUsage]);
							NSNumber *second = @([(DiskUsageInfo *)b diskUsage]);
							return [first compare:second];
						}];
					break;

				case kSortDescending:
				default:
					sortedDiskUsageArray =
						(NSMutableArray *)[diskUsageArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
							NSNumber *first = @([(DiskUsageInfo *)a diskUsage]);
							NSNumber *second = @([(DiskUsageInfo *)b diskUsage]);
							return [second compare:first];
						}];
					break;
			}
			break;

		case kSortByName:
			switch (sortOrder)
			{
				case kSortAscending:
					sortedDiskUsageArray =
						(NSMutableArray *)[diskUsageArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
							NSString *first = [(DiskUsageInfo *)a itemName];
							NSString *second = [(DiskUsageInfo *)b itemName];
							return [first compare:second];
						}];
					break;

				case kSortDescending:
				default:
					sortedDiskUsageArray =
						(NSMutableArray *)[diskUsageArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
							NSString *first = [(DiskUsageInfo *)a itemName];
							NSString *second = [(DiskUsageInfo *)b itemName];
							return [second compare:first];
						}];
					break;
			}
			break;

		case kSortByNone:
		default:
			break;
	}

	return sortedDiskUsageArray;
}

- (NSString *)buildFolderUsage:(DiskUsageInfo *)folderDiskUsage withPrefix:(NSString *)prefix folderOnly:(BOOL)folderOnly
{
	NSMutableString *usageString = [[NSMutableString alloc] init];
	NSString *byteString = nil;
	NSString *lineString = nil;

	// 1. this folder's usage

	byteString = [NSByteCountFormatter stringFromByteCount:folderDiskUsage.diskUsage countStyle:NSByteCountFormatterCountStyleFile];

	// shortcut out of here if only showing folder usage

	if (folderOnly)
	{
		return [NSString stringWithFormat:@"%@: %@",folderDiskUsage.itemName,byteString];
	}

	lineString = [NSString stringWithFormat:@"%@%@ %@: %@",prefix,FOLDER_SYMBOL,folderDiskUsage.itemName,byteString];

	HBLogDebug(@"buildFolderUsage: appending folder line: [%@]",lineString);

	[usageString setString:lineString];

	// 2. this folder's per-app usage, if desired

	if ([[FUPreferences sharedInstance] showAppUsage])
	{
		folderDiskUsage.containedApps =
			[self
				sortDiskUsageArray:folderDiskUsage.containedApps
				sortType:[[FUPreferences sharedInstance] appSortType]
				sortOrder:[[FUPreferences sharedInstance] appSortOrder]
			];

		for (DiskUsageInfo *app in folderDiskUsage.containedApps)
		{
			byteString = [NSByteCountFormatter stringFromByteCount:app.diskUsage countStyle:NSByteCountFormatterCountStyleFile];
			lineString = [NSString stringWithFormat:@"%@%@%@ %@: %@",prefix,INDENT_STRING,APP_SYMBOL,app.itemName,byteString];

			HBLogDebug(@"buildFolderUsage: appending app line: [%@]",lineString);

			[usageString appendFormat:@"\n%@",lineString];
		}
	}

	// this folder's per-folder usage, if desired

	if ([[FUPreferences sharedInstance] showSubfolderUsage])
	{
		folderDiskUsage.containedFolders =
			[self
				sortDiskUsageArray:folderDiskUsage.containedFolders
				sortType:[[FUPreferences sharedInstance] subfolderSortType]
				sortOrder:[[FUPreferences sharedInstance] subfolderSortOrder]
			];

		for (DiskUsageInfo *folder in folderDiskUsage.containedFolders)
		{
			lineString = [self buildFolderUsage:folder withPrefix:[prefix stringByAppendingString:INDENT_STRING] folderOnly:folderOnly];

			[usageString appendFormat:@"\n%@",lineString];
		}
	}

	return (NSString *)usageString;
}

- (AlertInfo *)createUsageAlert:(FolderUsageInfo *)folderUsage
{
	AlertInfo *alert = [[AlertInfo alloc] init];

	alert.useAlertView = SYSTEM_VERSION_LESS_THAN(@"9.0");
	alert.alertTitle = FULocalizedStringForKey(@"ALERT_TITLE");
	alert.alertAction = FULocalizedStringForKey(@"ALERT_OK");
	alert.initialAlertMessage = @"";
	alert.alertMessage = [self buildFolderUsage:folderUsage.diskUsage withPrefix:@"" folderOnly:folderUsage.folderOnly];

	// per-alert-handler pre-formatting

	if (alert.useAlertView)
		alert.alertMessage = [NSString stringWithFormat:@"%@\n\n",alert.alertMessage];

	// generic attributed string setup

	NSMutableAttributedString *attributedAlertMessage = [[NSMutableAttributedString alloc] initWithString:alert.alertMessage];

	NSRange alertRange = NSMakeRange(0,[alert.alertMessage length]);

//	UIFont *alertFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	UIFont *alertFont = [UIFont systemFontOfSize:13];

//	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];

	if (folderUsage.folderOnly)
		[paragraphStyle setAlignment:NSTextAlignmentCenter];
	else
		[paragraphStyle setAlignment:NSTextAlignmentLeft];

	// per-alert-handler post-formatting

	if (alert.useAlertView)
	{
		CGFloat margin = 20.0;

		paragraphStyle.headIndent = margin;
		paragraphStyle.firstLineHeadIndent = margin;
		paragraphStyle.tailIndent = -margin;

		CGFloat tabInterval = 28.0;

		NSMutableArray *tabs = [NSMutableArray array];

		for (NSInteger i=0;i<12;i++)
			[tabs addObject:[[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft location:margin+((i+1)*tabInterval) options:[NSDictionary dictionary]]];

//		paragraphStyle.defaultTabInterval = tabInterval;
		paragraphStyle.tabStops = tabs;
	}

	[attributedAlertMessage addAttribute:NSFontAttributeName value:alertFont range:alertRange];
	[attributedAlertMessage addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:alertRange];

	alert.attributedAlertMessage = attributedAlertMessage;

	return alert;
}

- (void)displayUsageAlertUsingUIAlertController:(AlertInfo *)alert
{
	HBLogDebug(@"displayUsageAlertUsingUIAlertController: using UIAlertController");

	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alert.alertTitle message:alert.initialAlertMessage preferredStyle:UIAlertControllerStyleAlert];

	[alertController setValue:alert.attributedAlertMessage forKey:@"attributedMessage"];

	UIAlertAction *okButton = [UIAlertAction actionWithTitle:alert.alertAction style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { }];

	[alertController addAction:okButton];

	[alertController show];
}

- (void)displayUsageAlertUsingUIAlertView:(AlertInfo *)alert
{
	HBLogDebug(@"displayUsageAlertUsingUIAlertView: using UIAlertView");

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alert.alertTitle message:alert.initialAlertMessage delegate:nil cancelButtonTitle:alert.alertAction otherButtonTitles:nil];
#pragma GCC diagnostic pop

	UILabel *alertLabel = [[UILabel alloc] initWithFrame:CGRectZero];

	alertLabel.attributedText = alert.attributedAlertMessage;
	alertLabel.numberOfLines = 0;
	[alertLabel sizeToFit];

	[alertView setValue:alertLabel forKey:@"accessoryView"];

	[alertView show];
}

- (void)displayUsageAlert:(AlertInfo *)alert
{
	if (alert.useAlertView)
		[self displayUsageAlertUsingUIAlertView:alert];
	else
		[self displayUsageAlertUsingUIAlertController:alert];
}

- (void)showUsageForFolder:(id)folder
{
	FolderUsageInfo *folderUsage = [[FolderUsageInfo alloc] init];

	// collect disk usage
	folderUsage.diskUsage = [self getUsageForFolder:folder];

	// determine if we are outputting folder info only (will affect formatting of alerts)
	folderUsage.folderOnly = ((![[FUPreferences sharedInstance] showAppUsage] || (0 == [folderUsage.diskUsage.containedApps count])) &&
		(![[FUPreferences sharedInstance] showSubfolderUsage] || (0 == [folderUsage.diskUsage.containedFolders count])));

	// create and format alert
	folderUsage.alert = [self createUsageAlert:folderUsage];

	// display alert
	[self displayUsageAlert:folderUsage.alert];
}

#if 0
- (void)showUsageForHomeScreen:(id)folder
{
	[self showUsageForFolder:folder withFolderName:FULocalizedStringForKey(@"HOME_SCREEN_NAME")];
}
#endif

@end

// vim:ft=objc
