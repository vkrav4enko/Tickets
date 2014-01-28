//
//  Image.h
//  TicketBuying
//
//  Created by Владимир on 26.01.14.
//  Copyright (c) 2014 Rost's company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) Event *event;

@end
