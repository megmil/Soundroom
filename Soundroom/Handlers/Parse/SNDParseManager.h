//
//  QueryManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/20/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface SNDParseManager : NSObject

@property (nonatomic, strong) PFQuery *queryForAcceptedInvitations; // TODO: rename all
@property (nonatomic, strong) PFQuery *queryForAllRoomMembers;
@property (nonatomic, strong) PFQuery *queryForCurrentQueue;
@property (nonatomic, strong) PFQuery *queryForScoreUpdates;

+ (instancetype)shared;

+ (void)deleteAllObjects:(NSArray *)objects;

+ (PFQuery *)queryForUserVotesWithSongId:(NSString *)songId;
+ (PFQuery *)queryForAllVotesWithSongId:(NSString *)songId;

@end

NS_ASSUME_NONNULL_END
