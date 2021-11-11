#import "Tweak.h"

// Thanks to CydaiDEV, Hearse


HBPreferences *preferences;

LAPolicy policy = LAPolicyDeviceOwnerAuthentication;
NSString *reason = @"Use your passcode to view and manage hidden album.";

BOOL enabled;
BOOL itemCountEnabled;
BOOL passwordAuthEnabled;
BOOL isAuthenticated;
BOOL authOnAppStart;
BOOL popToEnabled;
static BOOL accessed = nil;
static BOOL numeric;
static BOOL userDidLogin;
static BOOL didPresentWC;

double itemCount = 0;

/* iPad
%group iPad
%hook PUSidebarViewController
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"Tapped!");
	if (indexPath.row == 9) {
		NSLog(@"Tapped indexPath:%ld", indexPath.row);
		LAContext *context = [[LAContext alloc] init];
		NSError *authError = nil;
		if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&authError]) {
			[context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:NSLocalizedString(@"Use your passcode to view and manage hidden album.", nil) reply:^(BOOL success, NSError *error) {
				dispatch_async(dispatch_get_main_queue(), ^{
				if (success) {
					%orig;
				} else {
					
				}
				});
			}];
		}
	} else {
		%orig;
	}
}
%end
%end
*/

%group HiddenLock14
%hook PXNavigationListItem
- (id)initWithIdentifier:(id)arg1 title:(id)arg2 itemCount:(long long)arg3{
    if ([arg2 containsString:@"Hidden"] && itemCountEnabled){
        return %orig(arg1,arg2,itemCount);
    } else {
        return %orig;
    }
}
%end

%hook PXNavigationListGadget
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"Value for userDidLogin: %d", userDidLogin);
	//NSLog(@"Section: %ld, Row:%ld, Item:%ld, Desc:%@", indexPath.section, indexPath.row, indexPath.item, indexPath.description);
	if ([[[NSUserDefaults alloc] init] boolForKey:@"HiddenAlbumVisible"] == 1) {
		NSString *cellLabel = [[[tableView cellForRowAtIndexPath: indexPath] textLabel] text];
		if (indexPath.row == 1 && [cellLabel isEqualToString:@"Hidden"])  {
			NSLog(@"%@", cellLabel);
		    LAContext *context = [[LAContext alloc] init];
		    NSError *authError = nil;
		    if ([context canEvaluatePolicy:policy error:&authError]) {
			    [context evaluatePolicy:policy localizedReason:reason reply:^(BOOL success, NSError *error) {
				    dispatch_async(dispatch_get_main_queue(), ^{
					    if (success) {
							accessed = YES;
						    %orig;
					    } else {
							dispatch_async(dispatch_get_main_queue(), ^{
								switch(error.code) {
									case LAErrorUserFallback:
										NSLog(@"UserFallBack!");
									break;
									
									case LAErrorPasscodeNotSet:
										NSLog(@"PasscodeNotSet");
									break;

									case LAErrorAuthenticationFailed:
										NSLog(@"Authentication failed!");
									break;
									
									case LAErrorUserCancel:
										NSLog(@"User did cancel!");
									break;
								}
							});

						    [tableView deselectRowAtIndexPath:indexPath animated:YES];
					    }
				    });
			    }];
		    } else {
			UIViewController *rootVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
			UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.apple.mobileslideshow"];
				if(![preferences objectForKey:@"userDidLogin"] || ![keychain stringForKey:@"hlpassword"]) {
					UIAlertController *authFailed = [UIAlertController alertControllerWithTitle:@"Authentication failed" message:@"You have not set a proper Authentication method.\n Please proceed setting a password." preferredStyle:UIAlertControllerStyleAlert];
					UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
					UIAlertAction *authenticateAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
						NSString *password = ((UITextField *)authFailed.textFields[0]).text;
						NSString *passwordDouble = ((UITextField *)authFailed.textFields[1]).text;
						if (password.length < 4) {
							UIAlertController *passwordLength = [UIAlertController alertControllerWithTitle:@"Password too short" message:@"Please enter a password that contains more than 4 characters" preferredStyle:UIAlertControllerStyleAlert];
							UIAlertAction *passwordLengthAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
							[rootVC presentViewController:authFailed animated:YES completion:nil];
							}];
							[passwordLength addAction:passwordLengthAction];
							[rootVC presentViewController:passwordLength animated:YES completion:nil];
						} else {
							if ([password isEqualToString:passwordDouble]) {
								;
                            	[keychain setString:password forKey:@"hlpassword"];
								[preferences setBool:YES forKey:@"userDidLogin"];
								%orig;
							} else {
								UIAlertController *pwMatch = [UIAlertController alertControllerWithTitle:@"Passwords do not match" message:@"Please make sure the passwords you enter match." preferredStyle:UIAlertControllerStyleAlert];
								UIAlertAction *pwMatchAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
									[rootVC presentViewController:authFailed animated:YES completion:nil];
								}];
								[pwMatch addAction:pwMatchAction];
								[rootVC presentViewController:pwMatch animated:YES completion:nil];
							}
						}
					}];
					[authFailed addTextFieldWithConfigurationHandler:^(UITextField *textField) {
						textField.placeholder = @"Enter a password";
						textField.secureTextEntry = YES;
						if (numeric) {
							textField.keyboardType = UIKeyboardTypeNumberPad;
						} else {
							textField.keyboardType = UIKeyboardTypeDefault;
						}
					}];
					[authFailed addTextFieldWithConfigurationHandler:^(UITextField *textField1) {
						textField1.placeholder = @"Confirm your password";
						textField1.secureTextEntry = YES;
						if (numeric) {
							textField1.keyboardType = UIKeyboardTypeNumberPad;
						} else {
							textField1.keyboardType = UIKeyboardTypeDefault;
						}
					}];
					[authFailed addAction:cancel];
					[authFailed addAction:authenticateAction];
					[rootVC presentViewController:authFailed animated:YES completion:nil];
			    	[tableView deselectRowAtIndexPath:indexPath animated:YES];
					%orig;
				}
				else {
					UIAlertController *pwAuth = [UIAlertController alertControllerWithTitle:@"Password required" message:@"Use your password to view and manage hidden photos." preferredStyle:UIAlertControllerStyleAlert];
					UIAlertAction *dismiss1 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
					UIAlertAction *login = [UIAlertAction actionWithTitle:@"Authenticate" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
						NSString *pspassword = ((UITextField *)pwAuth.textFields[0]).text;
						UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.apple.mobileslideshow"];
                        NSString *token = [keychain stringForKey:@"hlpassword"];
						if([token isEqualToString:pspassword]) {
							%orig;
						}
						else {
							UIAlertController *pwAuthFailed = [UIAlertController alertControllerWithTitle:@"Wrong password!" message:@"The password you entered is not correct!" preferredStyle:UIAlertControllerStyleAlert];
							UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
								[rootVC presentViewController:pwAuth animated:YES completion: nil];
							}];
							UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){}];
							[pwAuthFailed addAction:dismiss];
							[pwAuthFailed addAction:tryAgain];
							[rootVC presentViewController:pwAuthFailed animated:YES completion:nil];
						}
					}];
					[pwAuth addTextFieldWithConfigurationHandler:^(UITextField *textField) {
						textField.placeholder = @"Password";
						textField.secureTextEntry = YES;
						UIToolbar* toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        				toolbar.barTintColor = [UIColor colorWithRed:209.0f/255.0f green:212.0f/255.0f blue:217.0f/255.0f alpha:1.0];
						toolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneBtn)],nil];
        				textField.inputAccessoryView = toolbar;
						if (numeric) {
							textField.keyboardType = UIKeyboardTypeNumberPad;
							textField.returnKeyType = UIReturnKeyDone;
						} else {
							textField.keyboardType = UIKeyboardTypeDefault;
							textField.returnKeyType = UIReturnKeyDone;
						}
					}];
					[pwAuth addAction: dismiss1];
					[pwAuth addAction:login];
					[rootVC presentViewController:pwAuth animated: YES completion:nil];
					[tableView deselectRowAtIndexPath:indexPath animated:YES];
					%orig;
				}
		    }
	    } else {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		    %orig;
	    }
	} else {
			%orig;
	}
}
%new
-(void)doneBtn {
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}
%end

%hook PUAlbumsGadgetViewController
- (void)_applicationWillEnterForeground: (id)arg1 {
	if (accessed && popToEnabled) {
		[self.navigationController popToRootViewControllerAnimated:YES];
		accessed = NO;
	}
	%orig;
}
%end
%end

%group NSB
%hook NSBundle
- (NSDictionary *)infoDictionary {
    NSDictionary *plist = %orig;
	NSMutableDictionary *mPlist = [plist mutableCopy] ?: [NSMutableDictionary dictionary];
    [mPlist setValue:@"Use FaceID to view and manage hidden photos." forKey:@"NSFaceIDUsageDescription"];
    return mPlist;
}
%end
%end

void resetPassword() {
	[preferences setBool:NO forKey:@"userDidLogin"];
	if ([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.mobileslideshow"]) {
		UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"com.apple.mobileslideshow"];
		[keychain removeItemForKey:@"hlpassword"];
		NSLog(@"received, bool:%d", userDidLogin);
	}
}

%ctor {
	%init(_ungrouped);
	preferences = [[HBPreferences alloc] initWithIdentifier:@"com.yan.hiddenlockpreferences"];
	[preferences registerBool:&enabled default:YES forKey:@"enabled"];
	if (!enabled) return;

	[preferences registerDouble:&itemCount default:0 forKey:@"itemCount"];
	[preferences registerBool:&itemCountEnabled default:YES forKey:@"itemCountEnabled"];
	[preferences registerBool:&passwordAuthEnabled default:NO forKey:@"passwordAuthEnabled"];
	[preferences registerBool:&authOnAppStart default:NO forKey:@"authOnAppStart"];
	[preferences registerBool:&popToEnabled default:YES forKey:@"popToEnabled"];
	[preferences registerBool:&numeric default:NO forKey:@"numeric"];
	[preferences registerBool:&userDidLogin default:nil forKey:@"userDidLogin"];
	[preferences registerBool:&didPresentWC default:nil forKey:@"didPresentWC"];

	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/.installed_unc0ver"] || [[NSFileManager defaultManager] fileExistsAtPath:@"/.bootstrapped"]) {
		if (@available(iOS 14, *)) {
			NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Applications/MobileSlideShow.app/Info.plist"];
            if (dictionary[@"NSFaceIDUsageDescription"] == nil) {
                pid_t pid;
	            int status;
                const char* args[] = {"echo", "fire in the hole", NULL};
                posix_spawn(&pid, "/usr/libexec/lighter", NULL, NULL, (char* const*)args, NULL);
                waitpid(pid, &status, WEXITED);
			}
		}	
    } else {

	}
	if ([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.mobileslideshow"]) {
		%init(HiddenLock14);
		%init(NSB);
		if (@available(iOS 14, *)) {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			if (![[[defaults dictionaryRepresentation] allKeys] containsObject:@"HiddenAlbumVisible"]) {
				[defaults setBool:YES forKey:@"HiddenAlbumVisible"];
				[defaults synchronize];
			} else {
				NSLog(@"Key already set!");
			}
		}
	}
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)resetPassword, (CFStringRef)@"com.yan.hiddenlockpreferences/resetPassword", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}