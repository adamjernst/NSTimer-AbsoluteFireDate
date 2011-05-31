This category works around some surprising `NSTimer` behavior on iOS.

You would expect that the 
`initWithFireDate:interval:target:selector:userInfo:repeats:` method of 
`NSTimer` would create a timer that fires at, or after, the specified date. 
Not so on iOS, specifically with regard to background execution.

Suppose you create a timer that fires five minutes in the future:

    NSDate *d = [NSDate dateWithTimeIntervalSinceNow:60*5];
    NSTimer *t = [[NSTimer alloc] initWithFireDate:d 
                                          interval:0.0
                                            target:self 
                                          selector:@selector(fired:) 
                                          userInfo:nil
                                           repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];

The user runs your app at 10:00 and immediately switches apps (putting your 
app in the background). At 10:04 the user returns to your app.

**The timer will fire at 10:09, not 10:05.**

`NSTimer` fires based on time the app has spent in the foreground, not the
actual specified fire date. This is annoying behavior.

This category fixes the issue by manually fixing the timers when the app 
re-enters the foreground. Enjoy!
