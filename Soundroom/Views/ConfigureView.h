//
//  ConfigureView.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RoomListeningModeType) {
    PartyMode = 0,
    RemoteMode = 1
};

@protocol ConfigureViewDelegate

- (void)createRoom;
- (void)inviteMembers;

@end

@interface ConfigureView : UIView

@property (strong, nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) RoomListeningModeType listeningModeType;
@property (nonatomic, weak) id<ConfigureViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
