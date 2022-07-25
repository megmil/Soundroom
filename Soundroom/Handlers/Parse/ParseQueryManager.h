//
//  QueryManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/21/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#define RoomClass @"Room"
#define RequestClass @"Request"
#define UpvoteClass @"Upvote"
#define DownvoteClass @"Downvote"
#define InvitationClass @"Invitation"

#define userIdKey @"userId"
#define roomIdKey @"roomId"
#define requestIdKey @"requestId"
#define currentSongIdKey @"currentSongId"
#define isPendingKey @"isPending"
#define usernameKey @"username"

NS_ASSUME_NONNULL_BEGIN

@interface ParseQueryManager : NSObject

// live queries
+ (PFQuery *)queryForInvitationsForCurrentUser;
+ (PFQuery *)queryForSongsInCurrentRoom;
+ (PFQuery *)queryForUpvotesInCurrentRoom;
+ (PFQuery *)queryForDownvotesInCurrentRoom;

// user
+ (void)getUsersWithUsername:(NSString *)username completion:(PFArrayResultBlock)completion;

// room
+ (void)getRoomWithId:(NSString *)roomId completion:(PFObjectResultBlock)completion;
+ (void)getRoomsForInvitations:(NSArray *)invitations completion:(PFArrayResultBlock)completion;

// song
+ (void)getSongWithId:(NSString *)songId completion:(PFObjectResultBlock)completion;
+ (void)getSongsInCurrentRoomWithCompletion:(PFArrayResultBlock)completion;

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
+ (void)getInvitationsForCurrentRoomWithCompletion:(PFArrayResultBlock)completion;
+ (void)getInvitationsAcceptedForCurrentRoomWithCompletion:(PFArrayResultBlock)completion;
+ (void)getInvitationsForCurrentUserWithCompletion:(PFArrayResultBlock)completion;

// key values
+ (void)getSpotifyIdForSongWithId:(NSString *)songId completion:(PFStringResultBlock)completion;
+ (void)didCurrentUserAcceptRoomInvitationWithCompletion:(PFBooleanResultBlock)completion;
+ (void)didSendCurrentRoomInvitationToUserWithId:(NSString *)userId completion:(PFBooleanResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
