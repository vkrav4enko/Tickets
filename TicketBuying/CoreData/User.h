//
//  User.h
//  TicketBuying
//
//  Created by Владимир on 22.10.13.
//  Copyright (c) 2013 Rost's company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *subscriptions;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addSubscriptionsObject:(Event *)value;
- (void)removeSubscriptionsObject:(Event *)value;
- (void)addSubscriptions:(NSSet *)values;
- (void)removeSubscriptions:(NSSet *)values;

@end
