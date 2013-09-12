//
//  BlockBackground.m
//  arrived
//
//  Created by Gustavo Ambrozio on 29/11/11.
//  Copyright (c) 2011 N/A. All rights reserved.
//
#import <math.h>
#import "BlockBackground.h"

@implementation BlockBackground

static BlockBackground *_sharedInstance = nil;

+ (BlockBackground*)sharedInstance
{
    if (_sharedInstance != nil) {
        return _sharedInstance;
    }
    
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[self alloc] init];
        }
    }
    
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone*)zone
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [super allocWithZone:zone];
            return _sharedInstance;
        }
    }
    NSAssert(NO, @ "[BlockBackground alloc] explicitly called on singleton class.");
    return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;
}

- (oneway void)release
{
}

- (id)autorelease
{
    return self;
}

- (void)sizeToFill
{
    UIInterfaceOrientation o = [self orientation];
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    
    CGFloat center_y = (height / 2);
    CGFloat center_x = (width / 2);
    
    self.center = CGPointMake(center_x, center_y);
    
    if (UIInterfaceOrientationIsPortrait(o))
    {
        self.bounds = CGRectMake(0, 0, width, height);
    }
    else if (UIInterfaceOrientationIsLandscape(o))
    {
        self.bounds = CGRectMake(0, 0, height, width);
    }
}

- (id)init
{
    self = [super initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar;
        self.hidden = YES;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.5f];
    }
    return self;
}

- (UIInterfaceOrientation)orientation
{
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (CGFloat)statusBarHeight
{
    CGSize statusBarSize =[[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.height, statusBarSize.width);
}

- (void)addToMainWindow:(UIView *)view
{
    if (self.hidden)
    {
        self.alpha = 0.0f;
        self.hidden = NO;
        self.userInteractionEnabled = YES;
        [self makeKeyAndVisible];
    }
    
    if (self.subviews.count > 0)
    {
        ((UIView*)[self.subviews lastObject]).userInteractionEnabled = NO;
    }
    
    [self addSubview:view];
}

- (void)reduceAlphaIfEmpty
{
    if (self.subviews.count == 1)
    {
        self.alpha = 0.0f;
//        20120907JY - disabling this user interaction can cause issues with fast taps when showing alerts - thanks for finding Anagd.
//        self.userInteractionEnabled = NO;
    }
}

- (void)removeView:(UIView *)view
{
    [view removeFromSuperview];
    if (self.subviews.count == 0)
    {
        self.hidden = YES;
        [self resignKeyWindow];
    }
    else
    {
        ((UIView*)[self.subviews lastObject]).userInteractionEnabled = YES;
    }
}

@end
