//
//  Song.h
//  Soundroom
//
//  Created by Megan Miller on 7/23/22.
//

#import <Foundation/Foundation.h>
#import "Track.h"
#import "Request.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VoteState) {
    Upvoted = 1,
    NotVoted = 0,
    Downvoted = -1
};

extern NSString *const songScoreKey;

@interface Song : NSObject

@property (nonatomic, strong) Track *track;
@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, strong) NSString *spotifyId;
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic) VoteState voteState;

+ (void)songsWithRequests:(NSArray <Request *> *)requests completion:(void (^)(NSMutableArray <Song *> *songs))completion;
+ (void)songWithRequest:(Request *)request completion:(void (^)(Song *song))completion;
+ (void)loadVotesForQueue:(NSMutableArray <Song *> *)queue completion:(void (^)(NSMutableArray <Song *> *result))completion;

@end

NS_ASSUME_NONNULL_END
