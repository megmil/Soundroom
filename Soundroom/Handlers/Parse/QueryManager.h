//
//  QueryManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/21/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface QueryManager : NSObject

+ (void)getInvitationsAcceptedByCurrentUserWithCompletion:(PFArrayResultBlock)completion; // TODO: rename all?
+ (void)getInvitationsAcceptedForCurrentRoomWithCompletion:(PFArrayResultBlock)completion;
+ (void)getSongsInCurrentRoomWithCompletion:(PFArrayResultBlock)completion;
+ (void)getVotesInCurrentRoomWithCompletion:(PFArrayResultBlock)completion;
+ (void)getVotesByCurrentUserInCurrentRoomWithCompletion:(PFArrayResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
