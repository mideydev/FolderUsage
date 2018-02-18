#import "FUCreditsFFGlobalAlertControllerListController.h"

@implementation FUCreditsFFGlobalAlertControllerListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"FolderUsageCreditsFFGlobalAlertController" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
