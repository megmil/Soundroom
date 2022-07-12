//
//  QueueSong.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "QueueSong.h"

@implementation QueueSong

@dynamic queueSongID;
@dynamic score;
@dynamic requesterAvatarImageFile;
@dynamic song;

+ (nonnull NSString *)parseClassName {
    return @"QueueSong";
}

+ (void)addSong:(Song *)song completion:(PFBooleanResultBlock _Nullable)completion {
    QueueSong *queueSong = [QueueSong new];
    queueSong.song = song;
    queueSong.score = 0;
    
    PFUser *currentUser = [PFUser currentUser];
    queueSong.requesterAvatarImageFile = [currentUser valueForKey:@"avatarImageFile"];
    
    [room addObject:queueSong forKey:@"queue"];
    [room saveInBackgroundWithBlock:completion];
}

@end
