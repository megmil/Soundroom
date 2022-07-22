//
//  VoteManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/20/22.
//

#import <Foundation/Foundation.h>
#import "QueueSong.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VoteState) {
    Upvoted,
    Downvoted,
    NotVoted
};

@interface VoteManager : NSObject

+ (instancetype)shared;

- (void)getVoteStateForSongWithId:(NSString *)songId completion:(void (^)(VoteState voteState))completion;
- (void)resetLocalVotes;

+ (void)incrementSongWithId:(NSString *)songId byAmount:(NSNumber *)amount;
+ (void)loadScoresForQueue:(NSMutableArray <QueueSong *> *)queue completion:(void (^)(NSMutableArray <NSNumber *> * _Nullable scores))completion;
+ (void)getScoreForSongWithId:(NSString *)songId completion:(void (^)(NSNumber *result))completion;

@end

NS_ASSUME_NONNULL_END
