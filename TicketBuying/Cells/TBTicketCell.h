//
//  TBTicketCell.h
//  TicketBuying
//
//  Created by Владимир on 26.01.14.
//  Copyright (c) 2014 Rost's company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBTicketCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *preview;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
