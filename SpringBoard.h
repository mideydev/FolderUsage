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
@property (nonatomic, readonly) NSString *applicationIdentifier;
@property (nonatomic, readonly) NSString *itemName;
@property (nonatomic, readonly) NSString *shortVersionString;
@property (nonatomic, readonly) NSString *vendorName;

+ (id)applicationProxyForIdentifier:(id)arg1;

//- (id)applicationIdentifier;
//- (id)itemName;
- (id)localizedName;
- (id)localizedShortName;
//- (id)shortVersionString;
//- (id)vendorName;
@end

@interface SBIconController : UIViewController
+ (id)sharedInstance;
- (id)dockListView;
@end

@interface SBFolderView : UIView
@end

@interface SBRootFolder : SBFolder
@end

@interface SBRootFolderView : SBFolderView
@property(retain, nonatomic) SBRootFolder *folder; // @dynamic folder;
// FolderUsage:
- (void)showHomeScreenUsage:(UISwipeGestureRecognizer *)swipe;
@end

@interface SBIconListView : UIView
- (id)icons;
@end

@interface SBRootIconListView : SBIconListView
@end

@interface SBDockIconListView : SBRootIconListView
@end

@interface SBControlCenterController : UIViewController
+ (id)sharedInstance;
- (_Bool)isVisible;
@end

// vim:ft=objc
