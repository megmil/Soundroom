//
//  QueryManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/21/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Invitation.h"

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

// user
+ (void)getUsersWithUsername:(NSString *)username completion:(PFArrayResultBlock)completion;

// room
+ (void)getRoomWithId:(NSString *)roomId completion:(PFObjectResultBlock)completion;
+ (void)getRoomsWithPendingInvitationsToCurrentUserWithCompletion:(PFArrayResultBlock)completion;

// song
+ (void)getSongWithId:(NSString *)songId completion:(PFObjectResultBlock)completion;
+ (void)getSongsInCurrentRoomWithCompletion:(PFArrayResultBlock)completion;

// vote
+ (void)getVotesInCurrentRoomWithCompletion:(PFArrayResultBlock)completion;
+ (void)getVotesByCurrentUserInCurrentRoomWithCompletion:(PFArrayResultBlock)completion;
+ (void)getVotesForSongWithId:(NSString *)songId completion:(PFArrayResultBlock)completion;
+ (void)getVoteByCurrentUserForSongWithId:(NSString *)songId completion:(PFObjectResultBlock)completion;

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
