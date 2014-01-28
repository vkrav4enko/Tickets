//
//  TBWebEngine.m
//  TicketBuying
//
//  Created by Владимир on 08.10.13.
//  Copyright (c) 2013 Rost's company. All rights reserved.
//

#import "TBWebEngine.h"
#import "Event.h"
#import "User.h"
#import "Image.h"

@interface TBWebEngine ()
@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) RKManagedObjectStore *objectStore;
@property (nonatomic, assign) BOOL isInternet;
@end

@implementation TBWebEngine

+ (TBWebEngine *)sharedManager {
    static TBWebEngine *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[TBWebEngine alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self configureCoreData];
    }
    return self;
}

- (void) configureCoreData
{
    _baseURL = [NSURL URLWithString: @"http://ticket.meteor.com"];
    NSError *error = nil;
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (! success) {
        RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    }
    NSString *databaseFilename = [NSString stringWithFormat:@"Store.sqlite"];
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:databaseFilename];
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    if (! persistentStore) {
        RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
    }
    [managedObjectStore createManagedObjectContexts];
    
    _ponyDebugger = [PDDebugger defaultInstance];
    [_ponyDebugger connectToURL:[NSURL URLWithString:@"ws://127.0.0.1:9000/device"]];
    [_ponyDebugger enableNetworkTrafficDebugging];
    [_ponyDebugger forwardAllNetworkTraffic];
    [_ponyDebugger enableCoreDataDebugging];
    [_ponyDebugger addManagedObjectContext:[NSManagedObjectContext contextForCurrentThread] withName:@"My MOC"];
    
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    
    self.objectManager = [RKObjectManager managerWithBaseURL:_baseURL];
    self.objectStore = managedObjectStore;
    _objectManager.managedObjectStore = _objectStore;
    _objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    [_objectManager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    
    [RKObjectManager setSharedManager:_objectManager];
    [self configureMapping];
    [self configurateRouting];
    
    
    [_objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/api/events"];
        
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict];
        NSString *eventId;
        if (match) {
            eventId = [argsDict objectForKey:@"eventId"];
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
            return fetchRequest;
        }
        return nil;
    }];
}

+ (RKEntityMapping *)eventsMappingInManagedObjectStore:(RKManagedObjectStore *)store
{
    [RKEntityMapping setEntityIdentificationInferenceEnabled:YES];
    RKEntityMapping *eventsMapping = [RKEntityMapping mappingForEntityForName:@"Event" inManagedObjectStore:store];
    [eventsMapping setIdentificationAttributes:@[@"eventId"]];
    [eventsMapping addAttributeMappingsFromArray:@[ @"discount",
                                                    @"price",
                                                    @"latitude",
                                                    @"longitude",
                                                    @"title",
                                                    @"owner",
                                                    @"date",
                                                    @"city",
                                                    @"country",
                                                    @"street"]];
    
    [eventsMapping addAttributeMappingsFromDictionary:@{@"_id": @"eventId",
                                                        @"description": @"eventDescription"}];
    
    RKEntityMapping *imagesMapping = [RKEntityMapping mappingForEntityForName:@"Image" inManagedObjectStore:store];
    [imagesMapping setIdentificationAttributes:@[@"identifier"]];
    [imagesMapping addAttributeMappingsFromDictionary:@{@"url": @"imageUrl",
                                                        @"id": @"identifier"}];
    
    [eventsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"images" toKeyPath:@"images" withMapping:imagesMapping]];
    
    RKEntityMapping *usersMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:store];
    [usersMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"userId"]];
    [usersMapping setIdentificationAttributes:@[@"userId"]];
    [eventsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"users" toKeyPath:@"subscribers" withMapping:usersMapping]];
    
    return eventsMapping;
}

+ (RKEntityMapping *)usersMappingInManagedObjectStore:(RKManagedObjectStore *)store
{
    RKEntityMapping *usersMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:store];
    [usersMapping setIdentificationAttributes:@[@"userId"]];
    [usersMapping addAttributeMappingsFromDictionary:@{@"username": @"username",
                                                       @"_id": @"userId"}];
    
    return usersMapping;
}

- (void)configurateRouting {
    // Relationship Routing
    
    [_objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[Event class]
                                                         pathPattern:@"/api/events/:eventId"
                                                              method:RKRequestMethodGET]];
    [_objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[Event class]
                                                         pathPattern:@"/api/events/:eventId"
                                                              method:RKRequestMethodPUT]];
    [_objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[Event class]
                                                         pathPattern:@"/api/events/:eventId"
                                                              method:RKRequestMethodDELETE]];
    
    [_objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[User class]
                                                         pathPattern:@"/api/users/:userId"
                                                              method:RKRequestMethodGET]];
    [_objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[User class]
                                                         pathPattern:@"/api/users/:userId"
                                                              method:RKRequestMethodPUT]];
    [_objectManager.router.routeSet addRoute:[RKRoute routeWithClass:[User class]
                                                         pathPattern:@"/api/users/:userId"
                                                              method:RKRequestMethodDELETE]];
    
}

- (void)configureMapping
{
    RKEntityMapping *eventsMapping = [TBWebEngine eventsMappingInManagedObjectStore:_objectStore];
    RKEntityMapping *usersMapping = [TBWebEngine usersMappingInManagedObjectStore:_objectStore];
    
    //Event's descriptors
    RKResponseDescriptor *eventsGetResponceDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:eventsMapping
                                                                                                     method:RKRequestMethodGET
                                                                                                pathPattern:@"/api/events"
                                                                                                    keyPath:nil
                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor *eventGetResponceDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:eventsMapping
                                                                                                     method:RKRequestMethodGET
                                                                                                pathPattern:@"/api/events/:eventId"
                                                                                                    keyPath:nil
                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor *eventsPostResponceDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:eventsMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:@"/api/events"
                                                                                                     keyPath:nil
                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKResponseDescriptor *eventsPutResponceDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:eventsMapping
                                                                                                      method:RKRequestMethodPUT
                                                                                                 pathPattern:@"/api/events/:eventId"
                                                                                                     keyPath:nil
                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    RKRequestDescriptor *eventsRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[eventsMapping inverseMapping]
                                                                                         objectClass:[Event class]
                                                                                         rootKeyPath:nil
                                                                                              method:RKRequestMethodAny];
    
    //User's descriptors
    RKResponseDescriptor *usersGetResponceDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:usersMapping
                                                                                                     method:RKRequestMethodGET
                                                                                                pathPattern:@"/api/users"
                                                                                                    keyPath:nil
                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *userGetResponceDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:usersMapping
                                                                                                    method:RKRequestMethodGET
                                                                                               pathPattern:@"/api/users/:userId"
                                                                                                   keyPath:nil
                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKResponseDescriptor *usersPutResponceDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:usersMapping
                                                                                                     method:RKRequestMethodPUT
                                                                                                pathPattern:@"/api/users/:userId"
                                                                                                    keyPath:nil
                                                                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKRequestDescriptor *usersRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[usersMapping inverseMapping]
                                                                                         objectClass:[User class]
                                                                                         rootKeyPath:nil
                                                                                              method:RKRequestMethodAny];
    
    //Error descriptors
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"status" toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    
    [_objectManager addResponseDescriptorsFromArray:@[
                                                      eventsGetResponceDescriptor,
                                                      eventGetResponceDescriptor,
                                                      eventsPostResponceDescriptor,
                                                      eventsPutResponceDescriptor,
                                                      usersGetResponceDescriptor,
                                                      userGetResponceDescriptor,
                                                      usersPutResponceDescriptor,
                                                      errorResponseDescriptor
                                                      ]];
    
    [_objectManager addRequestDescriptorsFromArray:@[
                                                     usersRequestDescriptor,
                                                     eventsRequestDescriptor
                                                     ]];
    
}

- (void)getEventsSuccess:(WebEngineSuccess)success
                   failure:(WebEngineFaluire)failure
{
    [_objectManager getObjectsAtPath:@"/api/events"
                          parameters:nil
                             success:success
                             failure:failure];
    
    
}

- (void)getEvent:(Event *)event
         success:(WebEngineSuccess)success
         failure:(WebEngineFaluire)failure
{
    [_objectManager getObject:event
                         path:nil
                   parameters:nil
                      success:success
                      failure:failure];
}

- (void)postEvent:(Event *)event
          success:(WebEngineSuccess)success
          failure:(WebEngineFaluire)failure
{
    [_objectManager postObject:event
                          path:[@"/api/events" stringByAppendingString:[NSString stringWithFormat:@"?token=%@", _token]]
                    parameters:nil
                       success:success
                       failure:failure];
}

- (void)putEvent:(Event *)event
         success:(WebEngineSuccess)success
         failure:(WebEngineFaluire)failure
{
    //NSDictionary *params = @{@"token": token};
    [_objectManager putObject:event
                          path:[[@"/api/events/" stringByAppendingString:event.eventId] stringByAppendingString:[NSString stringWithFormat:@"?token=%@", _token]]
                    parameters: nil
                       success:success
                       failure:failure];
}

- (void)deleteEvent:(Event *)event
            success:(WebEngineSuccess)success
            failure:(WebEngineFaluire)failure
{
    [_objectManager deleteObject:event
                          path:[[@"/api/events/" stringByAppendingString:event.eventId] stringByAppendingString:[NSString stringWithFormat:@"?token=%@", _token]]
                    parameters:nil
                       success:success
                       failure:failure];
}

- (void)getUsersSuccess:(WebEngineSuccess)success
                 failure:(WebEngineFaluire)failure
{
    [_objectManager getObjectsAtPath:[@"/api/users" stringByAppendingString:[NSString stringWithFormat:@"?token=%@", _token]]
                          parameters:nil
                             success:success
                             failure:failure];
    
}

- (void)getUser:(User *)user
         success:(WebEngineSuccess)success
         failure:(WebEngineFaluire)failure
{
    [_objectManager getObject:user
                         path:[[@"/api/users/" stringByAppendingString:user.userId] stringByAppendingString:[NSString stringWithFormat:@"?token=%@", _token]]
                   parameters:nil
                      success:success
                      failure:failure];
}

- (void)putUser:(User *)user
        success:(WebEngineSuccess)success
        failure:(WebEngineFaluire)failure
{
    [_objectManager putObject:user
                         path:[[@"/api/users/" stringByAppendingString:user.userId] stringByAppendingString:[NSString stringWithFormat:@"?token=%@", _token]]
                   parameters:nil
                      success:success
                      failure:failure];
}

- (void)deleteUser:(User *)user
        success:(WebEngineSuccess)success
        failure:(WebEngineFaluire)failure
{
    [_objectManager deleteObject:user
                         path:[[@"/api/users/" stringByAppendingString:user.userId] stringByAppendingString:[NSString stringWithFormat:@"?token=%@", _token]]
                   parameters:nil
                      success:success
                      failure:failure];
}


@end
