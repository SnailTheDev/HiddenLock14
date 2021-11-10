#import <Foundation/Foundation.h>
#include "HLPRootListController.h"
#import "spawn.h"

@implementation HLPRootListController

- (instancetype)init {
	self = [super init];

	if (self) {
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];

		self.applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style: UIBarButtonItemStylePlain target: self action: @selector(applySettings)];
		self.applyButton.tintColor = [UIColor whiteColor];
		self.navigationItem.rightBarButtonItem= self.applyButton;
		self.navigationItem.titleView = [UIView new];

		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
		self.titleLabel.textColor = [UIColor whiteColor];
		self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO,
		self.titleLabel.text = @"HiddenLock14";
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
		[self.navigationItem.titleView addSubview:self.titleLabel];

		appearanceSettings.tintColor = [UIColor colorWithRed:0.22f green:0.85f blue:0.98f alpha:1.0];
		appearanceSettings.navigationBarTitleColor = [UIColor whiteColor];
		appearanceSettings.navigationBarBackgroundColor = [UIColor colorWithRed:0.34 green:0.83 blue:0.96 alpha:1.0];
		appearanceSettings.navigationBarTintColor = [UIColor whiteColor];
		appearanceSettings.translucentNavigationBar = YES;
		self.hb_appearanceSettings = appearanceSettings;

		self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
		self.iconView.contentMode = UIViewContentModeScaleAspectFit;
		self.iconView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HiddenLockPreferences.bundle/icon.png"];
		self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
		self.iconView.alpha = 0.0;
		[self.navigationItem.titleView addSubview:self.iconView];

		self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,200)];
		UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,200,200)];
		headerImageView.contentMode = UIViewContentModeScaleAspectFill;
		self.headerView.clipsToBounds = YES;
		headerImageView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/HiddenLockPreferences.bundle/Banner.png"];
		headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
		[self.headerView addSubview:headerImageView];

		[NSLayoutConstraint activateConstraints:@[
			[self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
        	[self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
        	[self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
        	[self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
			[self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
			[headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
            [headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
            [headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
            [headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
		]];
	}
	return self;
}


- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}
//https://stackoverflow.com/questions/5833216/number-pad-keyboard-not-show-return-key-in-iphone
// https://stackoverflow.com/questions/20192303/how-to-add-a-done-button-to-numpad-keyboard-in-ios

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;

    if (offsetY > 113) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
			self.titleLabel.alpha = 0.0;
        }];
    } else if (offsetY > -100 && offsetY < 113){	
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
			self.titleLabel.alpha = 1.0;
        }];
    }
	else {
		[UIView animateWithDuration:0.2 animations:^{
			self.iconView.alpha = 0.0;
			self.titleLabel.alpha = 0.0;
		}];
	}
}


-(void)applySettings {
	NSLog(@"Applying changes...");
	pid_t pid;
    int status;
    const char* args[] = {"killall", "-9", "MobileSlideShow", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
    waitpid(pid, &status, WEXITED);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tableHeaderView = self.headerView;
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];

}

- (void)resetPassword:(id)sender {
	UIAlertController *rstPwAlert = [UIAlertController alertControllerWithTitle:@"Reset password" message:@"" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *rstPwAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.yan.hiddenlock14/resetPassword", nil, nil, true);
	}];
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction * action {}];
	[rstPwAlert addAction:rstPwAction];
	// declare rootVC / self?
        [rootVC presentViewController:rstPwAlert animated:YES completion:nil];
														   
}
@end

