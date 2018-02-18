// FolderUsage

// hack to get view's view controller
// http://stackoverflow.com/questions/36763415/how-would-you-presentviewcontroller-from-subview

#define UIViewParentController(__view) ({ \
UIResponder *__responder = __view; \
while ([__responder isKindOfClass:[UIView class]]) \
__responder = [__responder nextResponder]; \
(UIViewController *)__responder; \
})

// springboard stuff

@interface SBIcon : NSObject
- (id)applicationBundleID;
@end

@interface SBIconListModel : NSObject
- (id)icons;
@end

@interface SBFolder : NSObject
@property(copy, nonatomic) NSString *displayName;
@property(readonly, copy, nonatomic) NSArray *lists;
@end

@interface SBIconView : UIView
@property(nonatomic) _Bool isEditing;
@end

@interface SBFolderIconView : SBIconView
- (id)folder;
// FolderUsage:
- (unsigned long long)getUsageForApplication:(NSString *)applicationIdentifier;
- (unsigned long long)getUsageForFolder:(id)folder;
- (void)showFolderUsage:(UISwipeGestureRecognizer *)swipe;
@end

@interface _LSQueryResult : NSObject
@end

@interface LSResourceProxy : _LSQueryResult
@end

@interface LSBundleProxy : LSResourceProxy
@end

@interface LSApplicationProxy : LSBundleProxy
@property (nonatomic, readonly) NSNumber *staticDiskUsage;
@property (nonatomic, readonly) NSNumber *dynamicDiskUsage;
+ (id)applicationProxyForIdentifier:(id)arg1;
@end

@interface SBIconController : UIViewController
+ (id)sharedInstance;
@end

// hooks

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
	}

	return retval;
}

%new
- (unsigned long long)getUsageForApplication:(NSString *)applicationIdentifier
{
	unsigned long long staticDiskUsage = 0;
	unsigned long long dynamicDiskUsage = 0;

	LSApplicationProxy *proxy = [%c(LSApplicationProxy) applicationProxyForIdentifier:applicationIdentifier];

	if (proxy)
	{
		staticDiskUsage = [[proxy staticDiskUsage] longLongValue];
		dynamicDiskUsage = [[proxy dynamicDiskUsage] longLongValue];

		HBLogDebug(@"getUsageForApplication: [%@] : static = %llu / dynamic = %llu",applicationIdentifier,staticDiskUsage,dynamicDiskUsage);
	}

	return staticDiskUsage + dynamicDiskUsage;
}

%new
- (unsigned long long)getUsageForFolder:(id)folder
{
	unsigned long long folderDiskUsage = 0;

	NSArray *lists = [folder lists];

	for (SBIconListModel *list in lists)
	{
		for (id icon in [list icons])
		{
			if ([icon isKindOfClass:NSClassFromString(@"SBApplicationIcon")])
			{
				HBLogDebug(@"getUsageForFolder: [%@] : [%@] icon: %@ (app)",[[self folder] displayName],[folder displayName],NSStringFromClass([icon class]));

				folderDiskUsage += [self getUsageForApplication:[icon applicationBundleID]];
			}
			else if ([icon isKindOfClass:NSClassFromString(@"SBFolderIcon")])
			{
				HBLogDebug(@"getUsageForFolder: [%@] : [%@] icon: %@ (folder)",[[self folder] displayName],[folder displayName],NSStringFromClass([icon class]));

				folderDiskUsage += [self getUsageForFolder:[icon folder]];
			}
			else
			{
				HBLogDebug(@"getUsageForFolder: [%@] : [%@] icon: %@ (unknown)",[[self folder] displayName],[folder displayName],NSStringFromClass([icon class]));
			}
		}
	}

	return folderDiskUsage;
}

%new
- (void)showFolderUsage:(UISwipeGestureRecognizer *)swipe
{
	NSString *folderName = [[self folder] displayName];

	HBLogDebug(@"showFolderUsage: [%@] : swiped",folderName);

	if ([self isEditing])
	{
		HBLogDebug(@"showFolderUsage: [%@] : ignored swipe in wiggle mode",folderName);
		return;
	}

	unsigned long long folderDiskUsage = [self getUsageForFolder:[self folder]];

	NSString *folderUsage = [NSByteCountFormatter stringFromByteCount:folderDiskUsage countStyle:NSByteCountFormatterCountStyleFile];

	HBLogDebug(@"showFolderUsage: [%@] : usage = %llu (%@)",folderName,folderDiskUsage,folderUsage);

	NSString *alertTitle = @"Folder Usage";
	NSString *alertMessage = [NSString stringWithFormat:@"%@: %@",folderName,folderUsage];
	NSString *alertAction = @"OK";

	UIViewController *alertViewController = UIViewParentController(self);

	if (alertViewController && [alertViewController respondsToSelector:@selector(presentViewController:animated:completion:)])
	{
		HBLogDebug(@"showFolderUsage: using UIAlertController");

		UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction* okButton = [UIAlertAction actionWithTitle:alertAction style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { }];

		[alert addAction:okButton];

		[alertViewController presentViewController:alert animated:YES completion:nil];
	}
	else
	{
		HBLogDebug(@"showFolderUsage: using UIAlertView");

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:alertAction otherButtonTitles:nil];
#pragma GCC diagnostic pop

		[alert show];
	}
}

%end

// vim:ft=objc
