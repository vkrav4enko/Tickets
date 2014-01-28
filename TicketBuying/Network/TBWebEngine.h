//
//  TBWebEngine.h
//  TicketBuying
//
//  Created by Владимир on 08.10.13.
//  Copyright (c) 2013 Rost's company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PonyDebugger/PonyDebugger.h>

@class Event, User;

typedef void (^WebEngineSuccess)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult);
typedef void (^WebEngineFaluire)(RKObjectRequestOperation *operation, NSError *error);

@interface TBWebEngine : NSObject
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) PDDebugger *ponyDebugger;

+ (TBWebEngine *)sharedManager;
- (void) configureCoreData;
- (void)getEventsSuccess:(WebEngineSuccess)success
                 failure:(WebEngineFaluire)failure;
- (void)getEvent:(Event *)event
         success:(WebEngineSuccess)success
         failure:(WebEngineFaluire)failure;
- (void)postEvent:(Event *)event
          success:(WebEngineSuccess)success
          failure:(WebEngineFaluire)failure;
- (void)putEvent:(Event *)event
         success:(WebEngineSuccess)success
         failure:(WebEngineFaluire)failure;
- (void)deleteEvent:(Event *)event
            success:(WebEngineSuccess)success
            failure:(WebEngineFaluire)failure;

- (void)getUser:(User *)user
        success:(WebEngineSuccess)success
        failure:(WebEngineFaluire)failure;
- (void)putUser:(User *)user
        success:(WebEngineSuccess)success
        failure:(WebEngineFaluire)failure;
- (void)deleteUser:(User *)user
        success:(WebEngineSuccess)success
        failure:(WebEngineFaluire)failure;
@end
