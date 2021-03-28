// modified version of 
// https://github.com/schneelittchen/Puck/blob/master/Prefs/PCKAppearanceSettings.m

#import "NPTRootListController.h"

@implementation NPTAppearanceSettings

- (UIColor *)tintColor {
    if(UIScreen.mainScreen.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ){
        return [UIColor colorWithRed: 0.40 green: 0.40 blue: 0.74 alpha: 1.00];
    }
    else{
        return [UIColor colorWithRed: 0.52 green: 0.52 blue: 0.87 alpha: 1.00];
    }
}

- (UIColor *)statusBarTintColor {

    return [UIColor whiteColor];

}

- (UIColor *)navigationBarTitleColor {

    return [UIColor whiteColor];

}

- (UIColor *)navigationBarTintColor {

    return [UIColor whiteColor];

}

- (UIColor *)tableViewCellSeparatorColor {

    return [UIColor colorWithWhite:0 alpha:0];

}

- (UIColor *)navigationBarBackgroundColor {

    if(UIScreen.mainScreen.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ){
        return [UIColor colorWithRed: 0.40 green: 0.40 blue: 0.74 alpha: 1.00];
    }
    else{
        return [UIColor colorWithRed: 0.52 green: 0.52 blue: 0.87 alpha: 1.00];
    }
}

- (BOOL)translucentNavigationBar {

    return YES;

}

@end