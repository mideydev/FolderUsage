@interface FUHandler : NSObject
@property (nonatomic,retain,readonly) NSBundle *tweakBundle;
- (void)showUsageForFolder:(id)folder;
//- (void)showUsageForHomeScreen:(id)folder;
@end

// vim:ft=objc
