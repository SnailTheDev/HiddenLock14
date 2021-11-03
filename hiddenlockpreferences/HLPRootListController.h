#import <Preferences/PSListController.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBRespringController.h>


@interface HLPRootListController : HBRootListController
@property(nonatomic, retain) UIBarButtonItem *applyButton;
@property(nonatomic, retain) UIView *headerView;
@property(nonatomic, retain) UIImageView *headerImageView;
@property(nonatomic, retain) UIImageView *iconView;
@property(nonatomic, retain) UILabel *titleLabel;
- (void)resetPassword:(id)sender;
//- (void)applySettings;
@end