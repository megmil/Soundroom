//
//  QueueSong.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Song.h"
#import "Realm/Realm.h"

NS_ASSUME_NONNULL_BEGIN

@interface QueueSong : RLMObject

@property (nonatomic, strong) NSString *idString;
@property (nonatomic) NSInteger score;
@property (nonatomic, strong) NSString *requesterProfilePictureString;
@property (nonatomic, strong) Song *song;

- (instancetype)initWithSong:(Song *)song;
- (void)addToQueue;

@end

NS_ASSUME_NONNULL_END
