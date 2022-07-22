//
//  QueryManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/21/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#define RoomClass @"Room"
#define QueueSongClass @"QueueSong"
#define VoteClass @"Vote"
#define InvitationClass @"Invitation"

#define userIdKey @"userId"
#define roomIdKey @"roomId"
#define songIdKey @"songId"
#define currentSongIdKey @"currentSongId"
#define isPendingKey @"isPending"
#define usernameKey @"username"

NS_ASSUME_NONNULL_BEGIN

@interface ParseQueryManager : NSObject

// live queries
+ (PFQuery *)queryForInvitationsAcceptedByCurrentUser;
+ (PFQuery *)queryForSongsInCurrentRoom;
+ (PFQuery *)queryForVotesInCurrentRoom;

// get PFObjects
+ (void)getUsersWithUsername:(NSString *)username completion:(PFArrayResultBlock)completion;
+ (void)getRoomWithId:(NSString *)roomId completion:(PFObjectResultBlock)completion;
+ (void)getSongWithId:(NSString *)songId completion:(PFObjectResultBlock)completion;
+ (void)getSongsInCurrentRoomWithCompletion:(PFArrayResultBlock)completion; // TODO: rename all?
+ (void)getVotesInCurrentRoomWithCompletion:(PFArrayResultBlock)completion;
+ (void)getVotesByCurrentUserInCurrentRoomWithCompletion:(PFArrayResultBlock)completion;
+ (void)getVotesForSongWithId:(NSString *)songId completion:(PFArrayResultBlock)completion;
+ (void)getVoteByCurrentUserForSongWithId:(NSString *)songId completion:(PFObjectResultBlock)completion;
+ (void)getInvitationWithId:(NSString *)invitationId completion:(PFObjectResultBlock)completion;
+ (void)getInvitationAcceptedByCurrentUserWithCompletion:(PFObjectResultBlock)completion;
+ (void)getInvitationsForCurrentRoomWithCompletion:(PFArrayResultBlock)completion;
+ (void)getInvitationsAcceptedForCurrentRoomWithCompletion:(PFArrayResultBlock)completion;

// get other values
+ (void)getSpotifyIdForSongWithId:(NSString *)songId completion:(PFStringResultBlock)completion;
+ (void)didCurrentUserAcceptRoomInvitationWithCompletion:(PFBooleanResultBlock)completion;
+ (void)didSendCurrentRoomInvitationToUserWithId:(NSString *)userId completion:(PFBooleanResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
