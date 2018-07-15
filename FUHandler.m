#import <Foundation/Foundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <objc/runtime.h>
#import "SpringBoard.h"
#import "FUHandler.h"
#import "FUPreferences.h"
#import "external/FFGlobalAlertController/UIAlertController+Window.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#import "external/BSAlertViewDelegateBlock/BSAlertViewDelegateBlock.h"
#pragma GCC diagnostic pop

#define FULocalizedStringForKey(key) [self.tweakBundle localizedStringForKey:key value:@"" table:nil]

#if 0
@"\u2002" - En Space
@"\u2003" - Em Space
@"\u2007" - Figure Space
@"\u2013" - En Dash
@"\u2014" - Em Dash
@"\u2022" - Bullet
@"\u2023" - Triangular Bullet
@"\u2043" - Hyphen Bullet

@"\u25A3" - square with black square inside
@"\u25BE" - Black Down-Pointing Small Triangle
@"\u25B8" - Black Right-Pointing Small Triangle
@"\u25E6" - White Bullet

@"\u2211" - N-Ary Summation
#endif

#define INDENT_STRING	@"\t"
#define FOLDER_SYMBOL	@"\u25BE"
#define APP_SYMBOL		@"\u25B8"
//#define COUNT_SYMBOL	@"\u2002"
#define COUNT_SYMBOL	@"\u2013"

@interface DiskUsageInfo : NSObject
@property(nonatomic,copy) NSString *itemName;
@property(nonatomic) unsigned long long diskUsage;
@property(nonatomic,strong) NSMutableArray *containedApps;
@property(nonatomic,strong) NSMutableArray *containedFolders;
@property(nonatomic) NSInteger totalNestedApps;
@property(nonatomic) NSInteger totalNestedFolders;
@end

@implementation DiskUsageInfo

- (DiskUsageInfo *)init
{
	self = [super init];

	if (self)
	{
		_itemName = nil;
		_diskUsage = 0;
		_containedApps = [[NSMutableArray alloc] init];
		_containedFolders = [[NSMutableArray alloc] init];
		_totalNestedApps = 0;
		_totalNestedFolders = 0;
	}

	return self;
}

@end

@interface AlertInfo : NSObject
@property(nonatomic) BOOL useAlertView;
@property(nonatomic,copy) NSString *alertTitle;
@property(nonatomic,copy) NSString *alertActionOK;
@property(nonatomic,copy) NSString *alertActionCopy;
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
		_alertActionOK = nil;
		_alertActionCopy = nil;
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

	LSApplicationProxy *proxy = [objc_getClass("LSApplicationProxy") applicationProxyForIdentifier:applicationIdentifier];

	if (proxy)
	{
		HBLogDebug(@"getUsageForApplication: applicationIdentifier : [%@]",[proxy applicationIdentifier]);
		HBLogDebug(@"getUsageForApplication: itemName              : [%@]",[proxy itemName]);
		HBLogDebug(@"getUsageForApplication: localizedName         : [%@]",[proxy localizedName]);
		HBLogDebug(@"getUsageForApplication: localizedShortName    : [%@]",[proxy localizedShortName]);
		HBLogDebug(@"getUsageForApplication: shortVersionString    : [%@]",[proxy shortVersionString]);
		HBLogDebug(@"getUsageForApplication: vendorName            : [%@]",[proxy vendorName]);
		HBLogDebug(@"getUsageForApplication: staticDiskUsage       : [%@]",[proxy staticDiskUsage]);
		HBLogDebug(@"getUsageForApplication: dynamicDiskUsage      : [%@]",[proxy dynamicDiskUsage]);

		switch ([[FUPreferences sharedInstance] appNameType])
		{
			case kAppLocalizedShortName:
				appDiskUsage.itemName = [proxy localizedShortName];

				if (!appDiskUsage.itemName)
					appDiskUsage.itemName = [proxy localizedName];

				break;

			case kAppItemName:
				appDiskUsage.itemName = [proxy itemName];

				if (!appDiskUsage.itemName)
					appDiskUsage.itemName = [proxy localizedName];

				break;

			case kAppIdentifier:
				appDiskUsage.itemName = [proxy applicationIdentifier];
				break;

			case kAppLocalizedName:
			default:
				appDiskUsage.itemName = [proxy localizedName];
				break;
		}

		if (!appDiskUsage.itemName)
			appDiskUsage.itemName = [proxy applicationIdentifier];

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

				folderDiskUsage.totalNestedApps++;

				[folderDiskUsage.containedApps addObject:thisAppUsageInfo];
			}
			else if ([icon isKindOfClass:NSClassFromString(@"SBFolderIcon")])
			{
				HBLogDebug(@"getUsageForFolder: [%@] : [%@] icon: %@ (folder)",swipedFolder,folderDiskUsage.itemName,NSStringFromClass([icon class]));

				DiskUsageInfo *thisFolderUsageInfo = [self getUsageForFolder:[icon folder]];

				folderDiskUsage.diskUsage += thisFolderUsageInfo.diskUsage;

				folderDiskUsage.totalNestedFolders++;

				folderDiskUsage.totalNestedApps += thisFolderUsageInfo.totalNestedApps;
				folderDiskUsage.totalNestedFolders += thisFolderUsageInfo.totalNestedFolders;

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

- (DiskUsageInfo *)getUsageForDock
{
	DiskUsageInfo *dockDiskUsage = [[DiskUsageInfo alloc] init];

	SBDockIconListView *dockListView = [[objc_getClass("SBIconController") sharedInstance] dockListView];

	for (id icon in [dockListView icons])
	{
		if ([icon isKindOfClass:NSClassFromString(@"SBApplicationIcon")])
		{
			HBLogDebug(@"getUsageForDock: [%@] icon: %@ (app)",dockDiskUsage.itemName,NSStringFromClass([icon class]));

			DiskUsageInfo *thisAppUsageInfo = [self getUsageForApplication:[icon applicationBundleID]];

			dockDiskUsage.diskUsage += thisAppUsageInfo.diskUsage;

			dockDiskUsage.totalNestedApps++;

			[dockDiskUsage.containedApps addObject:thisAppUsageInfo];
		}
		else if ([icon isKindOfClass:NSClassFromString(@"SBFolderIcon")])
		{
			HBLogDebug(@"getUsageForDock: [%@] icon: %@ (folder)",dockDiskUsage.itemName,NSStringFromClass([icon class]));

			DiskUsageInfo *thisFolderUsageInfo = [self getUsageForFolder:[icon folder]];

			dockDiskUsage.diskUsage += thisFolderUsageInfo.diskUsage;

			dockDiskUsage.totalNestedFolders++;

			dockDiskUsage.totalNestedApps += thisFolderUsageInfo.totalNestedApps;
			dockDiskUsage.totalNestedFolders += thisFolderUsageInfo.totalNestedFolders;

			[dockDiskUsage.containedFolders addObject:thisFolderUsageInfo];
		}
		else
		{
			HBLogDebug(@"getUsageForDock: [%@] icon: %@ (unknown)",dockDiskUsage.itemName,NSStringFromClass([icon class]));
		}
	}

	return dockDiskUsage;
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
		if ([[FUPreferences sharedInstance] showAppCounts] && (folderDiskUsage.totalNestedApps > 0))
		{
			NSString *totalString = @"";

			if (folderDiskUsage.totalNestedApps > [folderDiskUsage.containedApps count])
				totalString = [NSString stringWithFormat:@" / %lu",(unsigned long)folderDiskUsage.totalNestedApps];

			lineString = [NSString stringWithFormat:@"%@%@%@ %@: %lu%@",prefix,INDENT_STRING,COUNT_SYMBOL,
				FULocalizedStringForKey(@"APPS_NAME"),(unsigned long)[folderDiskUsage.containedApps count],totalString];

			[usageString appendFormat:@"\n%@",lineString];
		}

		if ([folderDiskUsage.containedApps count] > 0)
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
	}

	// this folder's per-folder usage, if desired

	if ([[FUPreferences sharedInstance] showSubfolderUsage])
	{
		if ([[FUPreferences sharedInstance] showSubfolderCounts] && (folderDiskUsage.totalNestedFolders > 0))
		{
			NSString *totalString = @"";

			if (folderDiskUsage.totalNestedFolders > [folderDiskUsage.containedFolders count])
				totalString = [NSString stringWithFormat:@" / %lu",(unsigned long)folderDiskUsage.totalNestedFolders];

			lineString = [NSString stringWithFormat:@"%@%@%@ %@: %lu%@",prefix,INDENT_STRING,COUNT_SYMBOL,
				FULocalizedStringForKey(@"SUBFOLDERS_NAME"),(unsigned long)[folderDiskUsage.containedFolders count],totalString];

			[usageString appendFormat:@"\n%@",lineString];
		}

		if ([folderDiskUsage.containedFolders count] > 0)
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
	}

	return (NSString *)usageString;
}

- (AlertInfo *)createUsageAlert:(FolderUsageInfo *)folderUsage withAlertTitle:(NSString *)alertTitle
{
	AlertInfo *alert = [[AlertInfo alloc] init];

	if ([[FUPreferences sharedInstance] forceModernAlerts])
		alert.useAlertView = NO;
	else
		alert.useAlertView = SYSTEM_VERSION_LESS_THAN(@"9.0");

	if (alertTitle)
		alert.alertTitle = alertTitle;
	else
		alert.alertTitle = FULocalizedStringForKey(@"ALERT_TITLE_FOR_FOLDER");

	alert.alertActionOK = FULocalizedStringForKey(@"ALERT_OK");
	alert.alertActionCopy = FULocalizedStringForKey(@"ALERT_COPY");
	alert.initialAlertMessage = @"";
	alert.alertMessage = [self buildFolderUsage:folderUsage.diskUsage withPrefix:@"" folderOnly:folderUsage.folderOnly];

	// per-alert-handler pre-formatting

	NSString *alertMessage = alert.alertMessage;

	if (alert.useAlertView)
		alertMessage = [NSString stringWithFormat:@"%@\n\n",alertMessage];

	// generic attributed string setup

	NSMutableAttributedString *attributedAlertMessage = [[NSMutableAttributedString alloc] initWithString:alertMessage];

	NSRange alertRange = NSMakeRange(0,[alert.alertMessage length]);

//	UIFont *alertFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	UIFont *alertFont = [UIFont systemFontOfSize:(CGFloat)[[FUPreferences sharedInstance] fontSize]];

//	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];

	if (folderUsage.folderOnly)
		[paragraphStyle setAlignment:NSTextAlignmentCenter];
	else
		[paragraphStyle setAlignment:NSTextAlignmentLeft];

	// per-alert-handler post-formatting

	CGFloat margin = (alert.useAlertView) ? 20.0 : 0.0;
//	CGFloat tabInterval = 28.0;
	CGFloat tabInterval = (CGFloat)[[FUPreferences sharedInstance] indentSize];

	paragraphStyle.headIndent = margin;
	paragraphStyle.firstLineHeadIndent = margin;
	paragraphStyle.tailIndent = -margin;

	NSMutableArray *tabs = [NSMutableArray array];

	for (NSInteger i=0;i<12;i++)
		[tabs addObject:[[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft location:margin+((i+1)*tabInterval) options:[NSDictionary dictionary]]];

//	paragraphStyle.defaultTabInterval = tabInterval;
	paragraphStyle.tabStops = tabs;

	[attributedAlertMessage addAttribute:NSFontAttributeName value:alertFont range:alertRange];
	[attributedAlertMessage addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:alertRange];

	alert.attributedAlertMessage = attributedAlertMessage;

	return alert;
}

#if 0
- (void)copyAttributedStringToPasteboard:(NSAttributedString *)attributedText
{
	HBLogDebug(@"copyAttributedStringToPasteboard");

	NSMutableDictionary *item = [[NSMutableDictionary alloc] init];

	NSData *rtf = [attributedText dataFromRange:NSMakeRange(0, attributedText.length)
					documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType}
					error:nil];

	if (rtf)
		[item setObject:rtf forKey:(id)kUTTypeFlatRTFD];

	[item setObject:attributedText.string forKey:(id)kUTTypeUTF8PlainText];

	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];

	pasteboard.items = @[item];
}
#endif

- (void)copyStringToPasteboard:(NSString *)text
{
	HBLogDebug(@"copyStringToPasteboard");

	NSString *copyText = [NSString stringWithFormat:@"%@\n",text];

	NSMutableDictionary *items = [[NSMutableDictionary alloc] init];

	[items setObject:copyText forKey:(id)kUTTypeUTF8PlainText];

	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];

	pasteboard.items = @[items];
}

- (void)displayUsageAlertUsingUIAlertController:(AlertInfo *)alert
{
	HBLogDebug(@"displayUsageAlertUsingUIAlertController: using UIAlertController");

	UIAlertController *alertController = [UIAlertController
											alertControllerWithTitle:alert.alertTitle
											message:alert.initialAlertMessage
											preferredStyle:UIAlertControllerStyleAlert];

	[alertController setValue:alert.attributedAlertMessage forKey:@"attributedMessage"];

	UIAlertAction *okButton = [UIAlertAction
								actionWithTitle:alert.alertActionOK
								style:UIAlertActionStyleDefault
								handler:^(UIAlertAction *action)
								{
									// do nothing
									HBLogDebug(@"displayUsageAlertUsingUIAlertController: tapped OK");
								}];

	if ([[FUPreferences sharedInstance] copyButtonEnabled])
	{
		UIAlertAction *copyButton = [UIAlertAction
									actionWithTitle:alert.alertActionCopy
									style:UIAlertActionStyleDefault
									handler:^(UIAlertAction *action)
									{
										HBLogDebug(@"displayUsageAlertUsingUIAlertController: tapped Copy");
										[self copyStringToPasteboard:alert.alertMessage];
									}];

		[alertController addAction:copyButton];
	}

	[alertController addAction:okButton];

	[alertController show];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)displayUsageAlertUsingUIAlertView:(AlertInfo *)alert
{
	HBLogDebug(@"displayUsageAlertUsingUIAlertView: using UIAlertView");

	UIAlertView *alertView = [[UIAlertView alloc]
								initWithTitle:alert.alertTitle
								message:alert.initialAlertMessage
								delegate:self
								cancelButtonTitle:nil
								otherButtonTitles:nil];

	if ([[FUPreferences sharedInstance] copyButtonEnabled])
	{
		BSAlertViewDelegateBlock *alertDelegate = [[BSAlertViewDelegateBlock alloc] initWithAlertView:alertView];

		alertDelegate.clickedButtonAtIndexBlock =
			^(UIAlertView* alertView,NSInteger buttonIndex)
			{
				HBLogDebug(@"displayUsageAlertUsingUIAlertView: tapped %@ (%ld)",[alertView buttonTitleAtIndex:buttonIndex],(long)buttonIndex);

				if (0 == buttonIndex)
				{
					[self copyStringToPasteboard:alert.alertMessage];
				}
			};

		[alertView addButtonWithTitle:alert.alertActionCopy];
	}

	[alertView addButtonWithTitle:alert.alertActionOK];

	UILabel *alertLabel = [[UILabel alloc] initWithFrame:CGRectZero];

	alertLabel.attributedText = alert.attributedAlertMessage;
	alertLabel.numberOfLines = 0;
	[alertLabel sizeToFit];

	[alertView setValue:alertLabel forKey:@"accessoryView"];

	[alertView show];
}
#pragma GCC diagnostic pop

- (void)displayUsageAlert:(AlertInfo *)alert
{
	if (alert.useAlertView)
		[self displayUsageAlertUsingUIAlertView:alert];
	else
		[self displayUsageAlertUsingUIAlertController:alert];
}

- (void)displayFolderUsage:(FolderUsageInfo *)folderUsage withAlertTitle:(NSString *)alertTitle
{
	// determine if we are outputting folder info only (will affect formatting of alerts)
	folderUsage.folderOnly = ((![[FUPreferences sharedInstance] showAppUsage] || (0 == [folderUsage.diskUsage.containedApps count])) &&
		(![[FUPreferences sharedInstance] showSubfolderUsage] || (0 == [folderUsage.diskUsage.containedFolders count])));

	// create and format alert
	folderUsage.alert = [self createUsageAlert:folderUsage withAlertTitle:alertTitle];

	// display alert
	[self displayUsageAlert:folderUsage.alert];
}

- (void)showUsageForFolder:(id)folder
{
	FolderUsageInfo *folderUsage = [[FolderUsageInfo alloc] init];

	// collect disk usage
	folderUsage.diskUsage = [self getUsageForFolder:folder];

	[self displayFolderUsage:folderUsage withAlertTitle:FULocalizedStringForKey(@"ALERT_TITLE_FOR_FOLDER")];
}

- (void)showUsageForDevice:(id)folder
{
	FolderUsageInfo *deviceUsage = [[FolderUsageInfo alloc] init];

	DiskUsageInfo *homeUsage;
	DiskUsageInfo *dockUsage;

	homeUsage = [self getUsageForFolder:folder];
	homeUsage.itemName = FULocalizedStringForKey(@"HOME_SCREEN_NAME");

	dockUsage = [self getUsageForDock];
	dockUsage.itemName = FULocalizedStringForKey(@"DOCK_NAME");

	deviceUsage.diskUsage = [[DiskUsageInfo alloc] init];
	deviceUsage.diskUsage.itemName = FULocalizedStringForKey(@"DEVICE_NAME");

	if ([[FUPreferences sharedInstance] groupByHomeScreenAndDock])
	{
		deviceUsage.diskUsage.diskUsage = homeUsage.diskUsage + dockUsage.diskUsage;
		[deviceUsage.diskUsage.containedFolders addObject:homeUsage];
		[deviceUsage.diskUsage.containedFolders addObject:dockUsage];
		deviceUsage.diskUsage.totalNestedApps = homeUsage.totalNestedApps + dockUsage.totalNestedApps;
		deviceUsage.diskUsage.totalNestedFolders = homeUsage.totalNestedFolders + dockUsage.totalNestedFolders + 2;
	}
	else
	{
		deviceUsage.diskUsage.diskUsage = homeUsage.diskUsage + dockUsage.diskUsage;
		[deviceUsage.diskUsage.containedApps addObjectsFromArray:homeUsage.containedApps];
		[deviceUsage.diskUsage.containedApps addObjectsFromArray:dockUsage.containedApps];
		[deviceUsage.diskUsage.containedFolders addObjectsFromArray:homeUsage.containedFolders];
		[deviceUsage.diskUsage.containedFolders addObjectsFromArray:dockUsage.containedFolders];
		deviceUsage.diskUsage.totalNestedApps = homeUsage.totalNestedApps + dockUsage.totalNestedApps;
		deviceUsage.diskUsage.totalNestedFolders = homeUsage.totalNestedFolders + dockUsage.totalNestedFolders;
	}

	[self displayFolderUsage:deviceUsage withAlertTitle:FULocalizedStringForKey(@"ALERT_TITLE_FOR_DEVICE")];
}

@end

// vim:ft=objc
