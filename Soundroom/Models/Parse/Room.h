//
//  Room.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RoomListeningModeType) {
    PartyMode = 0,
    RemoteMode = 1
};

@interface Room : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *hostId;
@property (nonatomic, strong) NSString *currentSongSpotifyId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) NSUInteger listeningMode;

- (instancetype)initWithTitle:(NSString *)title hostId:(NSString *)hostId listeningMode:(RoomListeningModeType)listeningMode;

@end

NS_ASSUME_NONNULL_END
