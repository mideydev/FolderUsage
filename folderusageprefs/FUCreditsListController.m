#import "FUCreditsListController.h"

@implementation FUCreditsListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"FolderUsageCredits" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
