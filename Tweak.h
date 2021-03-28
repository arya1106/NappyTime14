#import<UIKit/UIKit.h>
#import<Cephei/HBPreferences.h>

// https://stackoverflow.com/questions/7848766/how-can-we-programmatically-detect-which-ios-version-is-device-running-on
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface _UILegibilitySettings
@property(retain, nonatomic) UIColor *primaryColor;
@end

@interface CSCoverSheetViewController : UIViewController
@property (nonatomic, readonly) _UILegibilitySettings *legibilitySettings;
@end

@interface CSCombinedListViewController : UIViewController
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;
- (double)_minInsetsToPushDateOffScreen;
- (UIEdgeInsets)_listViewDefaultContentInsets;
-(void)willTransitionToPresented:(BOOL)arg1;
@end

@interface NCNotificationStructuredListViewController : UIViewController
@property(nonatomic, strong, readwrite) UIView *masterListView;
@end

@interface MTAlarm : NSObject
@property (nonatomic,readonly) NSDate * nextFireDate;
@property (nonatomic, assign, readwrite)NSUInteger hour;
@property (nonatomic, assign, readwrite)NSUInteger minute;
-(BOOL)isEnabled;
@end

@interface MTAlarmCache
@property (nonatomic,retain) MTAlarm * nextAlarm; 
@property (nonatomic,retain) MTAlarm * sleepAlarm; 
@property (nonatomic, strong, readwrite) NSMutableArray *orderedAlarms;
@property (nonatomic, strong, readwrite) NSMutableArray *sleepAlarms;
@end

@interface MTAlarmManager
@property (nonatomic,retain) MTAlarmCache * cache;
@end

@interface MTUIDigitalClockLabel : UIView{
	long long _hour;
	long long _minute;
}
@end

@interface MTAAlarmTableViewCell : UITableViewCell
@property (nonatomic, strong, readwrite)MTUIDigitalClockLabel *digitalClockLabel;
@property (nonatomic, strong, readwrite)UISwitch *enabledSwitch;
@property (nonatomic, assign, readwrite)BOOL isSleepAlarm;
@property (nonatomic, strong)UILabel *detailLabel;
-(void)updateCountdown;
@end

@interface MTASleepAlarmTableViewCell : UITableViewCell
@property (nonatomic, strong, readwrite)MTUIDigitalClockLabel *digitalClockLabel;
@property (nonatomic, strong)UILabel *detailLabel;
@end

@interface SBScheduledAlarmObserver : NSObject {
        MTAlarmManager* _alarmManager;
}
+(id)sharedInstance;
@end

@interface SBFLockScreenDateSubtitleDateView : UIView
@property (nonatomic, strong) UILabel *nappyTimeCountdown;
-(void)setString:(NSString*)arg1;
-(void)updateCountdown:(BOOL)willToggle;
@end

@interface JPWallpaperColourManager
+ (JPWallpaperColourManager *)sharedManager;
@property (nonatomic, retain) _UILegibilitySettings* settings;
@end

// clock global vars
MTUIDigitalClockLabel static *clockLabel;
MTAlarmManager static *sharedAlarmManager;

// clock preferences
BOOL static isEnabled;
BOOL static showSeconds;
BOOL static showDisabled;
BOOL static isEnabledForBedtime;
NSInteger static textStyle;
NSInteger static LSTextStyle;
NSInteger static clockAppCountdownThreshold;
BOOL static shouldIgnoreThresholdClockApp;

// LS Prefs
BOOL static isEnabledOnLS;
BOOL static showSecondsOnLS;
NSInteger static LSCountdownThreshold;
BOOL static alwaysShowLSCountdown;
BOOL static replaceStockDate;
BOOL static jellyfishEnabled;
BOOL static customPosition;
double static labelCustomXPos;
double static labelCustomYPos;

// global vars
HBPreferences *preferences;
BOOL static isNotiOS14 = SYSTEM_VERSION_LESS_THAN(@"14");

// LS Global Vars
UIColor *CSTintColor;
BOOL isTempHiding;
CGRect clockFrame;
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

// Future feature
BOOL moveNCList;

// styles:
// 0 = short
// 1 = medium
// 2 = long

// get the string to display
static NSString* remainingTime(NSDate *fromDate, NSDate *toDate,BOOL withSeconds, NSInteger withStyle){
	NSUInteger unitFlags =	NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:unitFlags fromDate:fromDate toDate:toDate options:0];
	int hours = [dateComponents hour];
	int minutes = [dateComponents minute];
	if(withSeconds){
		
		int seconds  = [dateComponents second];
		switch(withStyle){
		
		case 0:
			return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
		case 1:
			return [NSString stringWithFormat:@"%02dh %02dm %02ds", hours, minutes, seconds];
			break;
		case 2:
			return [NSString stringWithFormat:@"%d Hours %d Minutes %d Seconds", hours, minutes, seconds];
			break;
		default:
			return [NSString stringWithFormat:@"%d Hours %d Minutes %d Seconds", hours, minutes, seconds];
			break;
		}
	}
	else{

		switch(withStyle){
		
		case 0:
			return [NSString stringWithFormat:@"%02d:%02d", hours, minutes];
		case 1:
			return [NSString stringWithFormat:@"%02dh %02dm", hours, minutes];
			break;
		case 2:
			return [NSString stringWithFormat:@"%d Hours %d Minutes", hours, minutes];
			break;
		default:
			return [NSString stringWithFormat:@"%d Hours %d Minutes", hours, minutes];
			break;
		}
	}
}

// this method does what it says
static void loadPrefs(){
	[preferences registerBool:&isEnabledOnLS default:YES forKey:@"isEnabledOnLS"];
	[preferences registerBool:&showSecondsOnLS default:YES forKey:@"showSecondsOnLS"];
	[preferences registerInteger:&LSCountdownThreshold default:43200 forKey:@"LSCountdownThreshold"];
	[preferences registerBool:&isEnabled default:YES forKey:@"isEnabled"];
	[preferences registerBool:&showSeconds default:YES forKey:@"showSeconds"];
	[preferences registerBool:&showDisabled default:NO forKey:@"showDisabled"];
	[preferences registerBool:&isEnabledForBedtime default:YES forKey:@"isEnabledForBedtime"];
	[preferences registerInteger:&textStyle default:2 forKey:@"textStyle"];
	[preferences registerInteger:&LSTextStyle default:2 forKey:@"LSTextStyle"];
	[preferences registerBool:&alwaysShowLSCountdown default:NO forKey:@"alwaysShowLSCountdown"];
	[preferences registerBool:&customPosition default:NO forKey:@"customPosition"];
	[preferences registerDouble:&labelCustomXPos default:0 forKey:@"labelCustomXPos"];
	[preferences registerDouble:&labelCustomYPos default:0 forKey:@"labelCustomYPos"];
	[preferences registerInteger:&clockAppCountdownThreshold default:43200 forKey:@"ClockAppCountdownThreshold"];
	[preferences registerBool:&shouldIgnoreThresholdClockApp default:YES forKey:@"ignoreThresholdClockApp"];
	jellyfishEnabled = [[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/xyz.royalapps.jellyfish.list"];
}