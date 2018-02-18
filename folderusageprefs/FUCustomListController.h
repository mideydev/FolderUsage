#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "FUCustomListController.h"
#import "../FUPreferences.h"

#define FULocalizedStringForKey(key) [self.tweakBundle localizedStringForKey:key value:@"" table:nil]

@interface FUCustomListController : PSListController
@property (nonatomic,retain,readonly) NSMutableDictionary *tweakSettings;
@property (nonatomic,retain,readonly) NSBundle *tweakBundle;
@end

// vim:ft=objc
