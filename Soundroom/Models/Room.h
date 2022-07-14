//
//  Room.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "QueueSong.h"

NS_ASSUME_NONNULL_BEGIN

@interface Room : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray <NSString *> *memberIds;
@property (nonatomic, strong) NSMutableArray <QueueSong *> *queue;
//@property (nonatomic, strong) NSMutableArray *playedSongs;
//@property (nonatomic, strong) PFFileObject *coverImageFile;

+ (void)createRoomWithTitle:(NSString *)title completion:(PFBooleanResultBlock)completion;
+ (void)getRoomWithId:(NSString *)roomId completion:(PFObjectResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
