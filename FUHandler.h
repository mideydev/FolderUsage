@interface FUHandler : NSObject
@property (nonatomic,retain,readonly) NSBundle *tweakBundle;
- (void)showUsageForFolder:(id)folder;
- (void)showUsageForDevice:(id)folder;
@end

// vim:ft=objc
