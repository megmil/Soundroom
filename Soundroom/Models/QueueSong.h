//
//  QueueSong.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Song.h"
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface QueueSong : Song

@property (nonatomic) NSInteger score;
@property (nonatomic, strong) User *requester;

@end

NS_ASSUME_NONNULL_END
