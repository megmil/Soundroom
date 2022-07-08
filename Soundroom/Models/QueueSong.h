//
//  QueueSong.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Song.h"
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface QueueSong : NSObject

@property (nonatomic, strong) Song *song;
@property (nonatomic) NSInteger score;
@property (nonatomic, strong) User *requester;

- (instancetype)initWithSong:(Song *)song;
- (void)addToQueue;

@end

NS_ASSUME_NONNULL_END
