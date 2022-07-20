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

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *spotifyId;

+ (void)deleteAllQueueSongsWithRoomId:(NSString *)roomId;

@end

NS_ASSUME_NONNULL_END
