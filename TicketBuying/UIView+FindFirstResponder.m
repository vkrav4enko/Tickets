//
//  UIView+FindFirstResponder.m
//  Board Book
//
//  Created by Kob Ro on 14.11.12.
//  Copyright (c) 2012 AppliKey Solutions. All rights reserved.
//

#import "UIView+FindFirstResponder.h"

@implementation UIView (FindFirstResponder)

- (UIView *)findFirstResonder {
    if (self.isFirstResponder){
        return self;
    }
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findFirstResonder];
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    return nil;
}

- (BOOL)resignAllResponder {
    UIView *responderView = [self findFirstResonder];
    if (responderView != nil) {
        return [responderView resignFirstResponder];
    } else {
        return NO;
    }
}

@end
