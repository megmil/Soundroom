//
//  Song.m
//  Soundroom
//
//  Created by Megan Miller on 7/23/22.
//

#import "Song.h"
#import "ParseQueryManager.h"
#import "ParseUserManager.h"
#import "ParseQueryManager.h"
#import "SpotifySessionManager.h"
#import "SpotifyAPIManager.h"
#import "Upvote.h"
#import "Downvote.h"

NSString *const songScoreKey = @"score";

@implementation Song

- (instancetype)initWithRequestId:(NSString *)requestId userId:(NSString *)userId spotifyId:(NSString *)spotifyId track:(Track *)track  {
    
    self = [super init];
    
    if (self) {
        
        _requestId = requestId;
        _userId = userId;
        _spotifyId = spotifyId;
        _track = track;
        _score = @(0);
        _voteState = NotVoted;
        
    }
    
    return self;
    
}

+ (void)songsWithRequests:(NSArray <Request *> *)requests completion:(void (^)(NSMutableArray <Song *> *songs))completion {
    
    __block NSMutableArray <Song *> *result = [NSMutableArray arrayWithCapacity:requests.count];
    __block NSUInteger remainingRequests = requests.count;
    
    if (!requests || !requests.count) {
        completion(result);
        return;
    }
    
    for (Request *request in requests) {
        
        [self songWithRequest:request completion:^(Song *song) {
            
            if (song) {
                [result addObject:song];
            }
            
            if (--remainingRequests == 0) {
                completion(result);
            }
            
        }];
        
    }
    
}

+ (void)songWithRequest:(Request *)request completion:(void (^)(Song *song))completion {
    
    if (!request) {
        completion(nil);
        return;
    }
    
    [[SpotifyAPIManager shared] getTrackWithSpotifyId:request.spotifyId completion:^(Track *track, NSError *error) {
        Song *song = [[Song alloc] initWithRequestId:request.objectId userId:request.userId spotifyId:request.spotifyId track:track];
        completion(song);
    }];
    
}

+ (void)loadVotesForQueue:(NSMutableArray <Song *> *)queue completion:(void (^)(NSMutableArray <Song *> *result))completion {
    
    [ParseQueryManager getUpvotesInCurrentRoomWithCompletion:^(NSArray *upvotes, NSError *error) {
        
        [ParseQueryManager getDownvotesInCurrentRoomWithCompletion:^(NSArray *downvotes, NSError *error) {
            
            __block NSMutableArray <Song *> *result = [NSMutableArray arrayWithArray:queue];
            NSUInteger remainingVotes = upvotes.count + downvotes.count; // counter to completion
            
            if (remainingVotes == 0) {
                completion(result);
                return;
            }
            
            for (NSUInteger i = 0; i != upvotes.count; i++) {
                
                Upvote *upvote = upvotes[i];
                NSUInteger index = [[queue valueForKey:requestIdKey] indexOfObject:upvote.requestId];

                if (index != NSNotFound) {
                    
                    Song *song = result[index];
                    result[index].score = @(song.score.integerValue + 1);
                    if ([upvote.userId isEqualToString:[ParseUserManager currentUserId]]) {
                        song.voteState = Upvoted;
                    }
                    // TODO: [result replaceObjectAtIndex:index withObject:song];
                    
                }
                
                if (--remainingVotes == 0) {
                    completion(result);
                }
                
            }
            
            for (NSUInteger i = 0; i != downvotes.count; i++) {
                
                Downvote *downvote = downvotes[i];
                NSUInteger index = [[queue valueForKey:requestIdKey] indexOfObject:downvote.requestId];
                
                if (index != NSNotFound) {
                    
                    Song *song = result[index];
                    song.score = @(song.score.integerValue - 1);
                    if ([downvote.userId isEqualToString:[ParseUserManager currentUserId]]) {
                        song.voteState = Downvoted;
                    }
                    // TODO: [result replaceObjectAtIndex:index withObject:song];
                    
                }
                
                if (--remainingVotes == 0) {
                    completion(result);
                }
                
            }
            
        }];
        
    }];
    
}

- (void)songWithRequestId:(NSString *)requestId completion:(void (^)(Song *song))completion {
    
    [ParseQueryManager getSpotifyIdForRequestWithId:requestId completion:^(NSString *spotifyId, NSError *error) {
        
        if (!spotifyId) {
            completion(nil);
            return;
        }
        
        [[SpotifyAPIManager shared] getTrackWithSpotifyId:spotifyId completion:^(Track *track, NSError *error) {
            
            if (!track) {
                completion(nil);
                return;
            }
            
            Song *song = [self initWithRequestId:requestId spotifyId:spotifyId track:track];
            completion(song);
            
        }];
        
    }];
    
}

- (BOOL)isEqual:(id)object {
    
    if ([object isKindOfClass:[Song class]]) {
        Song *song = (Song *)object;
        return [self.requestId isEqualToString:song.requestId];
    }
    
    return NO;
}

@end
