//
//  QueryManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/21/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const RoomClass;
extern NSString *const RequestClass;
extern NSString *const UpvoteClass;
extern NSString *const DownvoteClass;
extern NSString *const InvitationClass;

extern NSString *const objectIdKey;
extern NSString *const userIdKey;
extern NSString *const roomIdKey;
extern NSString *const currentSongSpotifyIdKey;
extern NSString *const requestIdKey;
extern NSString *const isPendingKey;
extern NSString *const createdAtKey;
extern NSString *const usernameKey;

@interface ParseQueryManager : NSObject

// live queries
+ (PFQuery *)queryForInvitationsForCurrentUser;
+ (PFQuery *)queryForRequestsInCurrentRoom;
+ (PFQuery *)queryForUpvotesInCurrentRoom;
+ (PFQuery *)queryForDownvotesInCurrentRoom;
+ (PFQuery *)queryForCurrentRoom;

// user
+ (void)getUsersWithUsername:(NSString *)username completion:(PFArrayResultBlock)completion;

// room
+ (void)getRoomWithId:(NSString *)roomId completion:(PFObjectResultBlock)completion;
+ (void)getRoomsForInvitations:(NSArray *)invitations completion:(PFArrayResultBlock)completion;

// request
+ (void)getRequestWithId:(NSString *)requestId completion:(PFObjectResultBlock)completion;
+ (void)getRequestsInCurrentRoomWithCompletion:(PFArrayResultBlock)completion;

// upvote/downvote
+ (void)getUpvotesInCurrentRoomWithCompletion:(PFArrayResultBlock)completion;
+ (void)getDownvotesInCurrentRoomWithCompletion:(PFArrayResultBlock)completion;
+ (void)getUpvotesForRequestWithId:(NSString *)requestId completion:(PFArrayResultBlock)completion;
+ (void)getDownvotesForRequestWithId:(NSString *)requestId completion:(PFArrayResultBlock)completion;
+ (void)getUpvoteByCurrentUserForRequestWithId:(NSString *)requestId completion:(PFObjectResultBlock)completion;
+ (void)getDownvoteByCurrentUserForRequestWithId:(NSString *)requestId completion:(PFObjectResultBlock)completion;

// invitation
+ (void)getInvitationWithId:(NSString *)invitationId completion:(PFObjectResultBlock)completion;
+ (void)getInvitationAcceptedByCurrentUserWithCompletion:(PFObjectResultBlock)completion;
+ (void)getInvitationsAcceptedForCurrentRoomWithCompletion:(PFArrayResultBlock)completion;
+ (void)getInvitationsPendingForCurrentUserWithCompletion:(PFArrayResultBlock)completion;

// key values
+ (void)getSpotifyIdForRequestWithId:(NSString *)requestId completion:(PFStringResultBlock)completion;
+ (void)didCurrentUserAcceptRoomInvitationWithCompletion:(PFBooleanResultBlock)completion;
+ (void)didSendCurrentRoomInvitationToUserWithId:(NSString *)userId completion:(PFBooleanResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
