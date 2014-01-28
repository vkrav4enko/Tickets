//
//  TBAddressCell.h
//  TicketBuying
//
//  Created by Владимир on 07.10.13.
//  Copyright (c) 2013 Rost's company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TBAddressCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *preview;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;


@end
