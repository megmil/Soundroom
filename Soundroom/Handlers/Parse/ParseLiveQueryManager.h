//
//  ParseLiveQueryManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/22/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@import ParseLiveQuery;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ParseLiveQueryManagerUpdatedPendingInvitationsNotification;

@interface ParseLiveQueryManager : NSObject

+ (instancetype)shared;

- (void)configureUserLiveSubscriptions;
- (void)configureRoomLiveSubscriptions;
- (void)clearUserLiveSubscriptions;
- (void)clearRoomLiveSubscriptions;

@end

NS_ASSUME_NONNULL_END
