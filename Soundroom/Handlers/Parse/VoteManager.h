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

+ (NSNumber *)scoreForSong:(QueueSong *)song;

+ (void)incrementSongWithId:(NSString *)songId byAmount:(NSNumber *)amount;
+ (VoteState)voteStateForSongWithId:(NSString *)songId;
+ (NSNumber *)scoreForSongWithId:(NSString *)songId;

@end

NS_ASSUME_NONNULL_END
