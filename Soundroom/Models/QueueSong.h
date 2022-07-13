//
//  QueueSong.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface QueueSong : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *queueSongId;
@property (nonatomic, strong) NSString *spotifyId;
@property (nonatomic, strong) NSNumber *score;

+ (void)queueSongWithSpotifyId:(NSString *)spotifyId roomId:(NSString *)roomId
                    completion:(void(^)(BOOL succeeded, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
