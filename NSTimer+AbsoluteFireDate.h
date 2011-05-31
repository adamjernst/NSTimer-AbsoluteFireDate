//
//  NSTimer+AbsoluteFireDate.h
//  commuter
//
//  Created by Adam Ernst on 11/26/10.
//  Copyright 2010 cosmicsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSTimer (AbsoluteFireDate)

- (id)initWithAbsoluteFireDate:(NSDate *)date target:(id)target selector:(SEL)aSelector userInfo:(id)userInfo;

@end
