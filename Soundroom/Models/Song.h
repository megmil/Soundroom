//
//  Song.h
//  Soundroom
//
//  Created by Megan Miller on 7/23/22.
//

#import <Foundation/Foundation.h>
#import "EnumeratedTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class Track;
@class Request;

extern NSString *const songScoreKey;

@interface Song : NSObject

@property (nonatomic, strong) Track *track;
@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *upc;
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic) VoteState voteState;

+ (void)songsWithRequests:(NSArray <Request *> *)requests completion:(void (^)(NSArray <Song *> *songs))completion;
+ (void)songWithRequest:(Request *)request completion:(void (^)(Song *song))completion;

@end

NS_ASSUME_NONNULL_END
