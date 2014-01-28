//
//  TBAddEventController.h
//  TicketBuying
//
//  Created by Владимир on 27.01.14.
//  Copyright (c) 2014 Rost's company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateInputTableViewCell.h"

@class Event;

@interface TBAddEventController : UITableViewController <DateInputTableViewCellDelegate>
@property (nonatomic, strong) Event *eventForEdit;

@end
