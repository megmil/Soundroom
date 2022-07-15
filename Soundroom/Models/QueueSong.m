//
//  QueueSong.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "QueueSong.h"

@implementation QueueSong

@dynamic objectId;
@dynamic roomId;
@dynamic spotifyId;
@dynamic score;

+ (nonnull NSString *)parseClassName {
    return @"QueueSong";
}

+ (void)requestSongWithSpotifyId:(NSString *)spotifyId roomId:(NSString *)roomId completion:(PFBooleanResultBlock)completion {
    QueueSong *newSong = [QueueSong new];
    newSong.roomId = roomId;
    newSong.spotifyId = spotifyId;
    newSong.score = @(0);
    [newSong saveInBackgroundWithBlock:completion];
}

@end
