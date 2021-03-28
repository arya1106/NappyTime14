#import "Tweak.h"

%group ClockApp

// this is pretty much the same as the other hook, the only difference is that there is no iOS 13/12
// specific code since this view only exists on iOS 14
%hook MTASleepAlarmTableViewCell

-(void) didMoveToWindow{
	%orig;

	[self performSelector:@selector(didMoveToWindow) withObject:nil afterDelay:1];
	if(!isEnabledForBedtime) return;

	clockLabel = [self digitalClockLabel];

	NSInteger fireHour = MSHookIvar<NSInteger>(clockLabel,"_hour");
	NSInteger fireMinute = MSHookIvar<NSInteger>(clockLabel,"_minute");

	NSDate *fireDate;

	for (MTAlarm* alarm in [[MSHookIvar<MTAlarmManager*>([UIApplication sharedApplication], "_alarmManager") cache] sleepAlarms]){
		if(([alarm hour] == fireHour) && ([alarm minute] == fireMinute)){
			fireDate = [alarm nextFireDate];
			if(![alarm isEnabled]){
				return;
			}
		}
	}

	if(!fireDate) return;

	NSString *remainingTimeString = remainingTime([NSDate date], fireDate, showSeconds, textStyle);

	if(isNotiOS14){
		for (id subview in [[[self subviews] objectAtIndex:0] subviews]){
			if([subview isKindOfClass:%c(MTUIAlarmView)]){
				for (id view in [subview subviews]){
					if([view isKindOfClass:%c(UILabel)]){
						[view setText:remainingTimeString];
					}
				}
			}
		}
	} else {
		[[self detailLabel] setText:remainingTimeString];
	}

}

%end

// the meat and potatoes of this tweak, at least for the clock app
%hook MTAAlarmTableViewCell

-(id)initWithStyle:(NSInteger)arg1 reuseIdentifier:(id)arg2{
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(postNotification) userInfo:nil repeats:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCountdown) name:@"NappyTimeUpdateCountdownNotification" object:nil];
	return %orig;
}

-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

%new
-(void)postNotification{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NappyTimeUpdateCountdownNotification" object:self];
}

%new
-(void)updateCountdown{
		// check if the alarm is enabled
	UISwitch *alarmSwitch = [self enabledSwitch];	
	BOOL alarmState = MSHookIvar<BOOL>(alarmSwitch,"_on");
	
	// if the tweak is disabled for the clock app or it is a sleep alarm and the tweak is disabled for the bedtime alarm, exit
	if((!isEnabled) || ([self isSleepAlarm] && !isEnabledForBedtime)) return;

	// if the tweak is disabled for disabled alarms, exit
	if((!showDisabled) && !(alarmState)) return;

	// iterate through the subviews of the cell to find the clock label on iOS 13 and below
	if(isNotiOS14){
		for (UIView *tableCell in [self subviews]){
			if([tableCell isKindOfClass: %c(UITableViewCellContentView)]){
				for(UIView *alarmView in [tableCell subviews]){
					if([alarmView isKindOfClass: %c(MTUIAlarmView)]){
						for(UIView *labelView in [alarmView subviews]){
							if([labelView isKindOfClass: %c(MTUIDigitalClockLabel)]){
								clockLabel = (MTUIDigitalClockLabel *) labelView;
							}
						}
					}
				}
			}
		}
	}

	// access the clock label property on iOS 14
	else{
		clockLabel = [self digitalClockLabel];
	}

	NSDate* fireDate;
	NSTimeInterval timeUntilFire;

	// get the time the alarm will fire from the clock label
	NSInteger fireHour = MSHookIvar<NSInteger>(clockLabel,"_hour");
	NSInteger fireMinute = MSHookIvar<NSInteger>(clockLabel,"_minute");
	
	if([self isSleepAlarm]){
		fireDate = [[[MSHookIvar<MTAlarmManager*>([UIApplication sharedApplication], "_alarmManager") cache] sleepAlarm] nextFireDate];
		timeUntilFire = [fireDate timeIntervalSinceDate:[NSDate date]];
	}
	else{
		for(MTAlarm* alarm in [[MSHookIvar<MTAlarmManager*>([UIApplication sharedApplication], "_alarmManager") cache] orderedAlarms]){
			if(([alarm hour] == fireHour) && ([alarm minute] == fireMinute)){
				fireDate = [alarm nextFireDate];
				timeUntilFire = [fireDate timeIntervalSinceDate:[NSDate date]];
			}
		}
	}
	if( ![self isSleepAlarm] && (!shouldIgnoreThresholdClockApp) && (timeUntilFire>clockAppCountdownThreshold) ) return;	 

	// get the string that will be displayed based on the date and the user's preferences
	NSString *remainingTimeString = remainingTime([NSDate date], fireDate, showSeconds, textStyle);

	// once again iterate through subviews to find what we're looking for
	if (isNotiOS14){
		for (id subview in [[[self subviews] objectAtIndex: 0] subviews]){
			if ([subview isKindOfClass: %c(MTUIAlarmView)]){
				for (id view in [subview subviews]){
					if ([view isKindOfClass:%c(UILabel)]){
						[view setText:remainingTimeString];
					}
				}
			}
		}
	}
	else{
		[[self detailLabel] setText:remainingTimeString];
	}
}
%end

CGPoint lastOffset;
NSTimeInterval lastOffsetCapture;

%hook UITableView

- (void)setContentOffset:(CGPoint)contentOffset{
	%orig;
	if([[self nextResponder] isKindOfClass:%c(MTAAlarmTableViewController)]){
		CGPoint currentOffset = contentOffset;
		NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];

		NSTimeInterval timeDiff = currentTime - lastOffsetCapture;
		if(timeDiff > 0.01){
			CGFloat distance = currentOffset.y - lastOffset.y;
			CGFloat scrollSpeedNotAbs = distance / timeDiff;

			CGFloat scrollSpeed = fabs(scrollSpeedNotAbs);
			if(!(scrollSpeed > 2000)){
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NappyTimeUpdateCountdownNotification" object:self];	
			}
		lastOffset = currentOffset;
		lastOffsetCapture = currentTime;
		}
	}
}

%end

%end

%group SpringBoardCustomLabel


// meat and potatoes of the tweak for SpringBoard
%hook SBFLockScreenDateSubtitleDateView

%property (nonatomic, strong) UILabel *nappyTimeCountdown;
// remove the notification observer once the object is deallocated
-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	%orig;
}

// add the notification observer as the object is initialized
-(id)initWithFrame:(CGRect)arg1{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleCountdown) name:@"NappyTimeToggleLSCountdown" object:nil];
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCountdown:) userInfo:nil repeats:YES];
	if (![self nappyTimeCountdown] && !customPosition){
		self.nappyTimeCountdown = [[UILabel alloc] initWithFrame:self.bounds];
		[[self nappyTimeCountdown] setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	else if (![self nappyTimeCountdown] && customPosition) {
		self.nappyTimeCountdown = [[UILabel alloc] initWithFrame:CGRectMake(labelCustomXPos, labelCustomYPos, 300, 200)];
		[[self nappyTimeCountdown] sizeToFit];
	}
	return %orig;
}

// meat and potatoes of the SpringBoard Section of this tweak

%new
-(void)updateCountdown:(BOOL)willToggle{
	
    if(customPosition){
		[[self nappyTimeCountdown] setFrame:CGRectMake(labelCustomXPos, labelCustomYPos, 300, 200)];
	}
	[self addSubview:[self nappyTimeCountdown]];
	if(jellyfishEnabled){
		[[self nappyTimeCountdown] setTextColor:[[[%c(JPWallpaperColourManager) sharedManager] settings] primaryColor]];
		[[self nappyTimeCountdown] setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightBlack]];
	}
	else{
    	[[self nappyTimeCountdown].centerXAnchor constraintEqualToAnchor: [self centerXAnchor]].active = YES;
    	[[self nappyTimeCountdown].centerYAnchor constraintEqualToAnchor: [self centerYAnchor] constant:30].active = YES;
    	[[self nappyTimeCountdown].heightAnchor constraintEqualToConstant:50].active = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NappyTimeGetCSTint" object:nil];
		[[self nappyTimeCountdown] setTextColor:CSTintColor];
	}
	// get the firing date of the next alarm using SBScheduledAlarmObserver's sharedInstance
	// get the string to display based on the fire date and current date
	NSDate *fireDate = [[[MSHookIvar<MTAlarmManager *>([%c(SBScheduledAlarmObserver) sharedInstance], "_alarmManager") cache] nextAlarm] nextFireDate];
	NSString *remainingTimeString = remainingTime([NSDate date], fireDate, showSecondsOnLS, LSTextStyle);

	// check if fireDate exists, if it doesn't, you have no upcoming alarms
	if([[MSHookIvar<MTAlarmManager *>([%c(SBScheduledAlarmObserver) sharedInstance], "_alarmManager") cache] nextAlarm]){
		// if the tweak is enabled on the LS and the user wants to hide the clock based on the 
		// time to fire, check time remaining and respond accordingly
		if(isEnabledOnLS && !alwaysShowLSCountdown && !isTempHiding){

			// get the number of seconds remaining until the next alarm
			NSTimeInterval timeUntilFire = [fireDate timeIntervalSinceDate:[NSDate date]];

			if(timeUntilFire<LSCountdownThreshold){ // show countdown
				moveNCList = YES;
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NappyTimeMoveNC" object:nil];
				if(!willToggle)	[[self nappyTimeCountdown] setText:remainingTimeString];
				else {
					[UIView transitionWithView:[self nappyTimeCountdown] duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
					[[self nappyTimeCountdown] setText:remainingTimeString];
					} completion:nil];
				}
			}
			else{ // show stock date
				
				moveNCList = NO;
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NappyTimeMoveNC" object:nil];
				if(!willToggle) [[self nappyTimeCountdown] setText:@""];
				[UIView transitionWithView:[self nappyTimeCountdown] duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
					[[self nappyTimeCountdown] setText:@""];
				} completion:nil];
			}
		}
		// this case is triggered when the user always to show the countdown, the tweak is enabled, and 
		// the countdown is not hiding
		else if(isEnabledOnLS && !isTempHiding){

			moveNCList = YES;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NappyTimeMoveNC" object:nil];
			if(!willToggle)	[[self nappyTimeCountdown] setText:remainingTimeString];
			else {
				[UIView transitionWithView:[self nappyTimeCountdown] duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
				[[self nappyTimeCountdown] setText:remainingTimeString];
				} completion:nil];
			}
		}
		// this case is triggered when the countdown is always enabled but temporarily
		// hidden by the double tap gesture
		else{
			moveNCList = NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NappyTimeMoveNC" object:nil];
			if(!willToggle) [[self nappyTimeCountdown] setText:@""];
			[UIView transitionWithView:[self nappyTimeCountdown] duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
				[[self nappyTimeCountdown] setText:@""];
			} completion:nil];
		}
	}
	else if(!isTempHiding && [[MSHookIvar<MTAlarmManager *>([%c(SBScheduledAlarmObserver) sharedInstance], "_alarmManager") cache] nextAlarm]){
		// reserved for a future feature

		moveNCList = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NappyTimeMoveNC" object:nil];
	}
	else{
		moveNCList = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NappyTimeMoveNC" object:nil];
		if(!willToggle) [[self nappyTimeCountdown] setText:@""];
		[UIView transitionWithView:[self nappyTimeCountdown] duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
			[[self nappyTimeCountdown] setText:@""];
		} completion:nil];
	}
}

%new
// this method does what it says
- (void) toggleCountdown{
	// toggle the value of isTempHiding
	isTempHiding = !isTempHiding;

	// call setString so the clock updates immediately
	// the argument doesn't matter
	[self updateCountdown:YES];
}

%end

%hook CSCoverSheetViewController

-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	%orig;
}

// add an observer for the tint color and get the tint color
-(void)viewDidLoad{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTintColor) name:@"NappyTimeGetCSTint" object:nil];
	CSTintColor = [[self legibilitySettings] primaryColor];
	%orig;
}

%new
// does what it says
-(void)updateTintColor{
	CSTintColor = [[self legibilitySettings] primaryColor];
}

%end

// add the view that will capture the double tap gesture
%hook NCNotificationStructuredListViewController
-(void)viewDidLoad{
	%orig;

	// make the view and gesture recognizer
	UIView *gestureView = [[UIView alloc] initWithFrame:[self view].frame];
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(NappyTimeToggleLSCountdown)];

	// make the gesture recognizer listen for double taps and attach that to the view we just made
	[doubleTap setNumberOfTapsRequired: 2];
	[gestureView addGestureRecognizer: doubleTap];

	// autolayout stuff
	// Note: We're using the masterListView here since we want this view to scroll with the notifcations
	// if we don't do this, the view blocks the scorlling of the notifications
	[gestureView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self masterListView] addSubview: gestureView];
    [gestureView.centerXAnchor constraintEqualToAnchor: [[self masterListView] centerXAnchor]].active = YES;
	[gestureView.widthAnchor constraintEqualToConstant:[UIScreen mainScreen].bounds.size.width].active = YES;
    if(jellyfishEnabled){
		[gestureView.heightAnchor constraintEqualToConstant:120].active = YES;
	    [gestureView.topAnchor constraintEqualToAnchor: [[self masterListView] topAnchor] constant:-160].active = YES;
	}
	else{
	    [gestureView.topAnchor constraintEqualToAnchor: [[self masterListView] topAnchor] constant:-130].active = YES;
		[gestureView.heightAnchor constraintEqualToConstant:100].active = YES;
	}
	[gestureView setUserInteractionEnabled: YES];
}

%new
// send a notification to toggle the countown once the view is double tapped
-(void)NappyTimeToggleLSCountdown{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NappyTimeToggleLSCountdown" object:nil];
}
%end

// This is from Litten's Dress
// https://github.com/schneelittchen/Dress/blob/62b71b9d65f3919623d320ab12ae372634a43aa4/Tweak/Tweak.xm#L823
%hook CSCombinedListViewController

- (id)initWithNibName:(id)arg1 bundle:(id)arg2{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification) name:@"NappyTimeMoveNC" object:nil];
	return %orig;
}

- (UIEdgeInsets)_listViewDefaultContentInsets { // adjust notification list position depending on style
	if (!customPosition && !moveNCList) return %orig;
    UIEdgeInsets originalInsets = %orig;
    if(jellyfishEnabled) originalInsets.top += 17;
	else originalInsets.top+=10;
    return originalInsets;

}

%new
- (void) receiveTestNotification{
	[self viewWillAppear: YES];
}

%end


%end

%ctor {
	preferences = [[HBPreferences alloc] initWithIdentifier:@"com.arya06.nappytime14prefs"];
	loadPrefs();
	if([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"] && isEnabledOnLS){
		%init(SpringBoardCustomLabel);
	}

	if([[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.mobiletimer"]){
		%init(ClockApp);
	}

}