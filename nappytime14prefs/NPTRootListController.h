#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>
#import <Cephei/HBRespringController.h>

@interface NPTAppearanceSettings : HBAppearanceSettings
@end


@interface PSListController (Private)
- (void)_returnKeyPressed:(id)notification;
-(BOOL)containsSpecifier:(PSSpecifier *)arg1;
@end

@interface NPTRootListController : HBRootListController{
	UITableView * _table;
}
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIImageView *headerImageView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
-(void)setupWelcomeController;
-(void)dismissWelcomeController;
@end

@interface NSTask : NSObject
@property (copy) NSString *launchPath;
@property(copy) NSArray<NSString *> *arguments;
- (void)launch;
@end

@interface OBButtonTray : UIView
@property (nonatomic,retain) UIVisualEffectView * effectView;
- (void)addButton:(id)arg1;
- (void)addCaptionText:(id)arg1;;
@end

@interface OBBoldTrayButton : UIButton
-(void)setTitle:(id)arg1 forState:(unsigned long long)arg2;
+(id)buttonWithType:(long long)arg1;
@end

@interface OBWelcomeController : UIViewController
@property (nonatomic,retain) UIView * viewIfLoaded;
@property (nonatomic,strong) UIColor * backgroundColor;
@property (assign,nonatomic) BOOL _shouldInlineButtontray;
- (OBButtonTray *)buttonTray;
- (id)initWithTitle:(id)arg1 detailText:(id)arg2 icon:(id)arg3;
- (void)addBulletedListItemWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3;
@end

UIBlurEffect* blur;
UIVisualEffectView* blurView;
BOOL shouldShowWelcome;
OBWelcomeController *welcomeController; // Declaring this here outside of a method will allow the use of it later, such as dismissing.
HBPreferences *preferences;


