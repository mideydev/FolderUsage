#import "FUCreditsBSAlertViewDelegateBlockListController.h"

@implementation FUCreditsBSAlertViewDelegateBlockListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"FolderUsageCreditsBSAlertViewDelegateBlock" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
