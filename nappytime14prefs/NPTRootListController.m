// modified version of
// https://github.com/schneelittchen/Puck/blob/master/Prefs/PCKRootListController.m

// welcome modal from
// https://gist.github.com/nahtedetihw/f26c40e84e89c928c13e04aac3b2a4f8

#include "NPTRootListController.h"

@implementation NPTRootListController

- (instancetype)init {
	self = [super init];

	if(self){
		NPTAppearanceSettings *appearanceSettings = [[NPTAppearanceSettings alloc] init];
		self.hb_appearanceSettings = appearanceSettings;

		self.navigationItem.titleView = [UIView new];
		self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
		self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
		self.titleLabel.text = @"1.1.2";
		self.titleLabel.textColor = [UIColor whiteColor];
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
		[self.navigationItem.titleView addSubview:self.titleLabel];

		self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/NappyTime14Prefs.bundle/icon@3x.png"];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconView.alpha = 0.0;
        [self.navigationItem.titleView addSubview:self.iconView];

		[NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
        ]];
	}

	return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];

    //     NSArray *chosenIDs = @[@"X_AXIS_LABEL",@"X_AXIS_SLIDER", @"Y_AXIS_LABEL", @"Y_AXIS_SLIDER"];
    //     if(![self savedSpecifiers]) self.savedSpecifiers = [[NSMutableDictionary alloc] init];
    //     for(PSSpecifier *specifier in [self specifiersForIDs:chosenIDs]){
    //         [self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
    //     }
	}

	return _specifiers;
}

- (void) viewDidLoad{
	[super viewDidLoad];
	self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.headerImageView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/NappyTime14Prefs.bundle/banner.png"];
    self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.headerImageView.clipsToBounds = YES;

	[self.headerView addSubview:self.headerImageView];
    [NSLayoutConstraint activateConstraints:@[
        [self.headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
        [self.headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
        [self.headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
        [self.headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
    ]];

	_table.tableHeaderView = self.headerView;

    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.arya06.nappytime14prefs"];
    [preferences registerBool:&shouldShowWelcome default:YES forKey:@"shouldShowWelcome"];
    if(shouldShowWelcome){
    [self setupWelcomeController];
    [preferences setBool:NO forKey:@"shouldShowWelcome"];
    }

    // [self updateSpecifierVisibility:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    tableView.tableHeaderView = self.headerView;
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    CGRect frame = self.table.bounds;
    frame.origin.y = -frame.size.height;

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
    self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationController.navigationBar.translucent = YES;

    blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    [blurView setFrame:[[self view] bounds]];
    [blurView setAlpha:1.0];
    [[self view] addSubview:blurView];

    [UIView animateWithDuration:.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [blurView setAlpha:0.0];
    } completion:nil];

}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
    self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationController.navigationBar.translucent = YES;

}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGFloat offsetY = scrollView.contentOffset.y;

    if (offsetY > 110) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    }

}

-(void)respring{
	// this animation was theifed from Litten
	// https://github.com/schneelittchen/Puck/blob/bcc5915ce44f28f554b55ddcdd9659502c7ea44b/Prefs/PCKRootListController.m#L257

	blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    [blurView setFrame:self.view.bounds];
    [blurView setAlpha:0.0];
    [[self view] addSubview:blurView];

    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [blurView setAlpha:1.0];
    } completion:^(BOOL finished) {
        [HBRespringController respringAndReturnTo:[NSURL URLWithString:@"prefs:root=NappyTime14"]];
        NSTask *task = [[NSTask alloc] init];
		[task setLaunchPath:@"/usr/bin/sbreload"];
		[task launch];
    }];
}

// -(void)updateSpecifierVisibility:(BOOL)animated{
//     preferences = [[HBPreferences alloc] initWithIdentifier:@"com.arya06.nappytime14prefs"];
    
//     if(![preferences boolForKey:@"customPosition"]){
//         [self removeContiguousSpecifiers:[[self savedSpecifiers] allValues] animated:animated];
//     } 
//     if (![self containsSpecifier:[[self savedSpecifiers] objectForKey:@"X_AXIS_LABEL"]]){
//         [self insertContiguousSpecifiers:[[self savedSpecifiers] allValues] afterSpecifierID:@"CUSTOM_POSITION_SWITCH" animated:animated];
//     }
// }

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    [super setPreferenceValue:value specifier:specifier];
    NSString *key = [specifier propertyForKey:@"key"];
    if([key isEqualToString:@"customPosition"] || [key isEqualToString:@"isEnabledOnLS"]){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Respring Needed" message:@"The change you made needs a respring in order to apply. Respring now?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* respringAction = [UIAlertAction actionWithTitle:@"Yeah" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self respring];
        }];
        UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:@"Nah" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:dismissAction];
        [alert addAction:respringAction];
        [alert setPreferredAction:respringAction];
        [self presentViewController:alert animated:YES completion:nil];
    }

    // [self updateSpecifierVisibility:YES];
}

// -(void)reloadSpecifiers{
//     [super reloadSpecifiers];

//     [self updateSpecifierVisibility:NO];
// }

-(void)jellyfishPresets{
    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.arya06.nappytime14prefs"];
    [preferences setDouble:0.0 forKey:@"labelCustomXPos" ];
    [preferences setDouble:-15.0 forKey:@"labelCustomYPos" ];
    [super viewDidLoad];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Jellyfish Presets" message:@"These should give you a reasonable starting point if you use Jellyfish, but you probably need to adjust them for your device. Would you like to respring to apply them?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* respringAction = [UIAlertAction actionWithTitle:@"Yeah" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self respring];
    }];
    UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:@"Nah" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:dismissAction];
    [alert addAction:respringAction];
    [alert setPreferredAction:respringAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)resetPrompt {

    UIAlertController* resetAlert = [UIAlertController alertControllerWithTitle:@"NappyTime14"
	message:@"Do you wish to start fresh?"
	preferredStyle:UIAlertControllerStyleAlert];
	
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Shoot" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self respring];
	}];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Maybe not" style:UIAlertActionStyleCancel handler:nil];

	[resetAlert addAction:confirmAction];
	[resetAlert addAction:cancelAction];

	[self presentViewController:resetAlert animated:YES completion:nil];
 
}

-(void)resetPreferences{
    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.arya06.nappytime14prefs"];
    [preferences removeAllObjects];
    [self resetPrompt];
}

-(void)setupWelcomeController { //This is an example method.

    // Create the OBWelcomeView with a title, a desription text, and an icon if you wish. Any of this can be nil if it doesn't apply to your view.
    welcomeController = [[OBWelcomeController alloc] initWithTitle:@"NappyTime14" detailText:nil icon:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/NappyTime14Prefs.bundle/iconFullRes.png"]];

    // Create a bulleted item with a title, description, and icon. Any of the parameters can be set to nil if you wish. You can have as little or as many of these as you wish. The view automatically compensates for adjustments.
    // As written here, systemImageNamed is an iOS 13 feature. It is available in the UIKitCore framework publically. You are welcome to use your own images just as usual. Make sure you set them up with UIImageRenderingModeAlwaysTemplate to allow proper coloring.
    [welcomeController addBulletedListItemWithTitle:@"Clock App" description:@"NappyTime shows countdowns in the stock clock app." image:[UIImage systemImageNamed:@"clock.fill"]];
    [welcomeController addBulletedListItemWithTitle:@"Lock Screen" description:@"NappyTime shows a countdown to your next alarm on the lock screen. Double tap the clock to toggle between the countdown and stock date." image:[UIImage systemImageNamed:@"lock.fill"]];
    [welcomeController addBulletedListItemWithTitle:@"Bugs, Questions, or Crashes?" description:@"Open an issue on GitHub, or DM me on Twitter. (@arya_1106)" image:[UIImage systemImageNamed:@"questionmark.circle.fill"]];
    // Create your button here, set some properties, and add it to the controller.
    OBBoldTrayButton* continueButton = [OBBoldTrayButton buttonWithType:1];
    [continueButton addTarget:self action:@selector(dismissWelcomeController) forControlEvents:UIControlEventTouchUpInside];
    [continueButton setTitle:@"Got it!" forState:UIControlStateNormal];
    [continueButton setClipsToBounds:YES]; // There seems to be an internal issue with the properties, so you may need to force this to YES like so.
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; // There seems to be an internal issue with the properties, so you may need to force this to be [UIColor whiteColor] like so.
    [continueButton.layer setCornerRadius:15]; // Set your button's corner radius. This can be whatever. If this doesn't work, make sure you make setClipsToBounds to YES.
    [welcomeController.buttonTray addButton:continueButton];
    
    // Set the Blur Effect Style of the Button Tray
    welcomeController.buttonTray.effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
    
    // Create the view that will contain the blur and set the frame to the View of welcomeController
    UIVisualEffectView *effectWelcomeView = [[UIVisualEffectView alloc] initWithFrame:welcomeController.viewIfLoaded.bounds];
    
    // Set the Blur Effect Style of the Blur View
    effectWelcomeView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
    
    // Insert the Blur View to the View of the welcomeController atIndex:0 to put it behind everything
    [welcomeController.viewIfLoaded insertSubview:effectWelcomeView atIndex:0];
    
    // Set the background to the View of the welcomeController to clear so the blur will show
    welcomeController.viewIfLoaded.backgroundColor = [UIColor clearColor];

    //The caption text goes right above the buttons, sort of like as a thank you or disclaimer. This is optional, and can be excluded from your project.
    [welcomeController.buttonTray addCaptionText:@"Thank you for installing NappyTime :)"];

    welcomeController.modalPresentationStyle = UIModalPresentationPageSheet; // The same style stock iOS uses.
    welcomeController.modalInPresentation = YES; //Set this to yes if you don't want the user to dismiss this on a down swipe.
    welcomeController.view.tintColor = [UIColor colorWithRed: 0.42 green: 0.42 blue: 0.86 alpha: 0.8]; // If you want a different tint color. If you don't set this, the controller will take the default color.
    welcomeController._shouldInlineButtontray = YES;
    [self presentViewController:welcomeController animated:YES completion:nil]; // Don't forget to present it!
}

-(void)dismissWelcomeController { // Say goodbye to your controller. :(
    [welcomeController dismissViewControllerAnimated:YES completion:nil];
}

@end
