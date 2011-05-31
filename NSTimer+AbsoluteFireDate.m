//
//  NSTimer+AbsoluteFireDate.m
//  commuter
//
//  Created by Adam Ernst on 11/26/10.
//  Copyright 2010 cosmicsoft. All rights reserved.
//

#import "NSTimer+AbsoluteFireDate.h"


@interface NSTimerAbsoluteFireDateTracker : NSObject {
	NSMutableArray *timers;
}
+ (NSTimerAbsoluteFireDateTracker *)sharedTracker;
- (void)trackTimer:(NSTimer *)timer;
@end


@implementation NSTimer (AbsoluteFireDate)

- (id)initWithAbsoluteFireDate:(NSDate *)date target:(id)target selector:(SEL)aSelector userInfo:(id)userInfo {
	NSTimer *timer = [self initWithFireDate:date interval:0.0 target:target selector:aSelector userInfo:userInfo repeats:NO];
	[[NSTimerAbsoluteFireDateTracker sharedTracker] trackTimer:timer];
	return timer;
}

@end


@implementation NSTimerAbsoluteFireDateTracker

- (id)init {
	if (self = [super init]) {
		timers = [[NSMutableArray alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTimers:) name:UIApplicationDidBecomeActiveNotification object:nil];
		if (&UIApplicationWillEnterForegroundNotification != NULL) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTimers:) name:UIApplicationWillEnterForegroundNotification object:nil];
		}
	}
	return self;
}

- (void)dealloc {
	if (&UIApplicationWillEnterForegroundNotification != NULL) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	[timers release];
	[super dealloc];
}

static NSTimerAbsoluteFireDateTracker *sharedTracker;
+ (NSTimerAbsoluteFireDateTracker *)sharedTracker {
	if (sharedTracker == nil) {
		sharedTracker = [[NSTimerAbsoluteFireDateTracker alloc] init];
	}
	return sharedTracker;
}

- (void)trackTimer:(NSTimer *)timer {
	[timers addObject:timer];
}

- (void)checkTimers:(NSNotification *)notification {
	NSMutableArray *timersToRemove = [NSMutableArray array];
	// The timers array might be mutated if a fired timer
	// in turn creates an absolute-fire-date timer of its own.
	// Make a copy to avoid this problem.
	NSArray *currentTimers = [timers copy];
	
	for (NSTimer *timer in currentTimers) {
		if ([timer isValid]) {
			if ([[NSDate date] timeIntervalSinceDate:[timer fireDate]] > 0.0) {
				[timer fire];
			} else {
				[timer setFireDate:[timer fireDate]];
			}
		}
		
		if (![timer isValid]) {
			[timersToRemove addObject:timer];
		}
	}
	
	[currentTimers release];
	
	[timers removeObjectsInArray:timersToRemove];
}

@end
