//
//  Event.h
//  TicketBuying
//
//  Created by Владимир on 22.10.13.
//  Copyright (c) 2013 Rost's company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image, User;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSNumber * discount;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) NSSet *subscribers;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addSubscribersObject:(User *)value;
- (void)removeSubscribersObject:(User *)value;
- (void)addSubscribers:(NSSet *)values;
- (void)removeSubscribers:(NSSet *)values;

@end
