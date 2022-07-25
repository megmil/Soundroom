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

@property (strong, nonatomic) PFLiveQueryClient *client;
@property (strong, nonatomic) PFLiveQuerySubscription *invitationSubscription;
@property (strong, nonatomic) PFLiveQuerySubscription *requestSubscription;
@property (strong, nonatomic) PFLiveQuerySubscription *upvoteSubscription;
@property (strong, nonatomic) PFLiveQuerySubscription *downvoteSubscription;
@property (strong, nonatomic) PFLiveQuerySubscription *roomSubscription;

- (void)configureUserLiveSubscriptions;
- (void)configureRoomLiveSubscriptions;
- (void)clearUserLiveSubscriptions;
- (void)clearRoomLiveSubscriptions;

@end

NS_ASSUME_NONNULL_END
