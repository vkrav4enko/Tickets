//
//  UIView+FindFirstResponder.h
//  Board Book
//
//  Created by Kob Ro on 14.11.12.
//  Copyright (c) 2012 AppliKey Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FindFirstResponder)

- (UIView *)findFirstResonder;
- (BOOL)resignAllResponder;

@end
