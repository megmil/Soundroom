//
//  Upvotes.h
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VoteState) {
    Upvoted,
    Downvoted,
    NotVoted
};

@interface Vote : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *songId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSNumber *increment;

+ (void)incrementSongWithId:(NSString *)songId byAmount:(NSNumber *)amount;
+ (VoteState)voteStateForSongWithId:(NSString *)songId;
+ (NSNumber *)scoreForSongWithId:(NSString *)songId;

@end

NS_ASSUME_NONNULL_END
