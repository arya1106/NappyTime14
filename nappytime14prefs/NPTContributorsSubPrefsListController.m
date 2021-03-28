  
#import <Preferences/PSListController.h>
#import <Preferences/PSListItemsController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>

@interface NPTAppearanceSettings : HBAppearanceSettings
@end

@interface NPTContributorsSubPrefsListController : HBListController
@property(nonatomic, retain)UILabel* titleLabel;
@end

@implementation NPTContributorsSubPrefsListController

-(instancetype)init{
	self = [super init];

	if(self){
		NPTAppearanceSettings *appearanceSettings = [[NPTAppearanceSettings alloc] init];
		self.hb_appearanceSettings = appearanceSettings;
	}

	return self;
}

-(id)specifiers{
	return _specifiers;
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];

    self.navigationController.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 0.42 green: 0.42 blue: 0.86 alpha: 1.00];
    [self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
    self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationController.navigationBar.translucent = YES;

}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {

    NSString *sub = [specifier propertyForKey:@"NPTSub"];
    NSString *title = [specifier name];

    _specifiers = [self loadSpecifiersFromPlistName:sub target:self];

    [self setTitle:title];
    [self.navigationItem setTitle:title];

}

- (void)setSpecifier:(PSSpecifier *)specifier {

    [self loadFromSpecifier:specifier];
    [super setSpecifier:specifier];

}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (bool)shouldReloadSpecifiersOnResume {

    return false;

}

@end