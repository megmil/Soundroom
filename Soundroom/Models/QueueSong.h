//
//  QueueSong.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Song.h"
#import "Room.h"
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface QueueSong : PFObject<PFSubclassing> // TODO: embedded NSObject

@property (nonatomic, strong) NSString *queueSongId;
@property (nonatomic) NSInteger score;
@property (nonatomic, strong) PFFileObject *requesterAvatarImageFile;
@property (nonatomic, strong) Song *song;

+ (void)addSong:(Song *)song completion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
