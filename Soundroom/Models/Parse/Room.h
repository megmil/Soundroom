//
//  Room.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Room : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *hostId;
@property (nonatomic, strong) NSString *currentSongId;

+ (void)createRoomWithTitle:(NSString *)title completion:(PFBooleanResultBlock _Nullable)completion;
+ (void)getRoomWithId:(NSString *)roomId completion:(PFObjectResultBlock _Nullable)completion;
+ (void)getCurrentRoomWithCompletion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END